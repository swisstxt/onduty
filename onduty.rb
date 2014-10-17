require 'twilio-ruby'
require 'sinatra'
require 'sqlite3'

set :environment, :development #(ENV["RACK_ENV"] || :development).to_sym

require "sinatra/activerecord"
require "./lib/onduty/alert"
require "./lib/onduty/contact"


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

post '/alert' do
  content_type 'text/xml'
  message = File.read('./alert.txt') rescue "Nothing. Sorry for the interruption."
  Twilio::TwiML::Response.new do |r|
    r.Say message, voice: "woman"
    r.Gather(numDigits: 1, action: '/acknowledge') do |g|
      g.Say "Please enter any key to acknowledge the message.", voice: "woman"
    end
    r.Say "We didn't receive any input. We will call you again. Goodbye!", voice: "woman"
  end.text
end

post '/acknowledge' do
  content_type 'text/xml'
  Twilio::TwiML::Response.new do |r|
    r.Say "The alert has been acknowledged. Thank you and Goodbye!", voice: "woman"
  end.text
end

get '/contacts' do
  @title = "Contacts"
  @contacts = Contact.all
  erb :"contacts/index"
end

get '/contacts/new' do
  @method = 'new'
  @title = "Create Contact"
  erb :"contacts/form"
end

post '/contacts/new' do
  contact = Contact.new(params[:contact])
  if contact.save
    redirect '/contacts'
  else
    redirect '/contacts/new'
  end
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
    redirect '/contacts'
  else
    'Error'
  end
end

delete '/contacts/delete/:id' do
  if Contact.find(params[:id]).destroy
    redirect '/contacts'
  else
    "Error"
  end
end

post '/contacts/:id/status' do
  Contact.where(status: params[:status]).update_all(status: 0)
  Contact.find(params[:id]).update(status: params[:status])
  redirect '/contacts'
end

post '/alert' do
  content_type 'text/xml'
  message = File.read('./alert.txt') rescue "Nothing. Sorry for the interruption."
  Twilio::TwiML::Response.new do |r|
    r.Say message, voice: "woman"
    r.Gather(numDigits: 1, action: '/acknowledge') do |g|
      g.Say "Please enter any key to acknowledge the message.", voice: "woman"
    end
    r.Say "We didn't receive any input. We will call you again. Goodbye!", voice: "woman"
  end.text
end

post '/acknowledge' do
  content_type 'text/xml'
  Twilio::TwiML::Response.new do |r|
    r.Say "The alert has been acknowledged. Thank you and Goodbye!", voice: "woman"
  end.text
end
