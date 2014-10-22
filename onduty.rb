require 'twilio-ruby'
require 'sinatra'
require 'sinatra/contrib'
require 'sqlite3'

set :environment, :development #(ENV["RACK_ENV"] || :development).to_sym

require "sinatra/activerecord"
require "sinatra/config_file"

c_file = nil
%w(/etc/onduty.yml /etc/onduty/onduty.yml ./config/onduty.yml ./config/onduty.example.yml).each do |config|
  if File.exists?(config)
    c_file = config
    break
  end
end
if c_file
  config_file c_file
else
  puts "Error: No configuration file found. Exit."
  exit 1
end

require "./lib/onduty/models/alert"
require "./lib/onduty/models/contact"
require "./lib/onduty/twilio_api"


helpers do
  def status_badge(status)
    case status
      when 1 then 'danger'
      when 2 then 'primary'
      else 'default'
    end
  end
end

get '/' do
  redirect '/contacts'
end

#################################
# Alerts
#

get '/alerts' do
  @title = "Alerts"
  @alerts = Alert.all
  erb :"alerts/index"
end

get '/alerts/new' do
  @method = 'new'
  @title = "Create Alert"
  @alert = Alert.new
  erb :"alerts/form"
end

post '/alerts/new' do
  alert = Alert.new(params[:alert])
  if alert.save
    redirect "/alerts"
  else
    redirect '/alerts/new'
  end
end

get '/alerts/:id' do
  @alert = Alert.find(params[:id])
  @title = @alert.id
  erb :"alerts/show"
end

post '/alerts/:id/acknowledge' do
  @alert = Alert.find(params[:id])
  @alert.acknowledged_at = Time.now
  @alert.save

  content_type 'text/xml'
  Twilio::TwiML::Response.new do |r|
    r.Say "The alert with ID #{@alert.id} has been acknowledged. Thank you and Goodbye!", voice: "woman"
  end.text
end

post '/alerts/:id' do
  content_type 'text/xml'
  @alert = Alert.find(params[:id])
  Twilio::TwiML::Response.new do |r|
    r.Say @alert.message, voice: "woman"
    r.Gather(numDigits: 1, action: "/alerts/#{@alert.id}/acknowledge") do |g|
      g.Say "Please enter any key to acknowledge the message.", voice: "woman"
    end
    r.Say "We didn't receive any input. We will call you again. Goodbye!", voice: "woman"
  end.text
end

post '/alerts/:id/alert' do
  @alert = Alert.find(params[:id])
  @contact = Contact.where(status: 1).first

  twilio = TwilioApi.new(settings.account_sid, settings.auth_token, settings.from_number)
  twilio.sms(@contact.phone, @alert.message)
  twilio.call(@contact.phone, URI::join(settings.base_url, "/alerts/#{@alert.id}"))

  @alert.last_alert_at = Time.now
  @alert.save

  redirect "/alerts/#{@alert.id}"
end

#################################
# Contacts
#

get '/contacts' do
  @title = "Contacts"
  @contacts = Contact.all
  erb :"contacts/index"
end

get '/contacts/new' do
  @method = 'new'
  @title = "Create Contact"
  @contact = Contact.new
  erb :"contacts/form"
end

post '/contacts/new' do
  contact = Contact.new(params[:contact])
  if contact.save
    redirect "/contacts/#{contact.id}"
  else
    redirect '/contacts/new'
  end
end

get '/contacts/:id' do
  @contact = Contact.find(params[:id])
  @title = @contact.name
  erb :"contacts/show"
end

get '/contacts/:id/edit' do
  @method = "#{params[:id]}/edit"
  @contact = Contact.find(params[:id])
  @title = "Edit Contact"
  erb :"contacts/form"
end

post '/contacts/:id/edit' do
  @contact = Contact.find(params[:id])
  if @contact.update(params[:contact])
    redirect "/contacts/#{@contact.id}"
  else
    'Error'
  end
end

delete '/contacts/:id/delete' do
  contact = Contact.find(params[:id])
  if params[:confirm_delete]
    if contact.destroy
      redirect '/contacts'
    else
      "Error"
    end
  else
    redirect "/contacts/#{contact.id}/delete"
  end
end

get '/contacts/:id/delete' do
  @contact = Contact.find(params[:id])
  @title = "Delete Contact"
  erb :"contacts/delete"
end

post '/contacts/:id/status' do
  Contact.where(status: params[:status]).update_all(status: 0)
  Contact.find(params[:id]).update(status: params[:status])
  redirect '/contacts'
end
