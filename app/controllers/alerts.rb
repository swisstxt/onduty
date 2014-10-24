#################################
# Alerts
#

get '/alerts' do
  @title = "Alerts"
  @alerts = case params[:days]
  when nil || ''
    Alert.created_after(days_ago(2))
  when 'all'
    Alert.all
  else
    Alert.created_after(days_ago(params[:days]))
  end

  @alerts = @alerts.acknowledged if params[:acknowledged] == 'true'
  @alerts = @alerts.unacknowledged if params[:acknowledged] == 'false'

  @alerts = @alerts.order(created_at: :desc)
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
    redirect "/alerts/#{alert.id}"
  else
    redirect '/alerts/new'
  end
end

get '/alerts/:id' do
  @alert = Alert.find(params[:id])
  @title = @alert.id
  erb :"alerts/show"
end

delete '/alerts/:id/delete' do
  alert = Alert.find(params[:id])
  if params[:confirm_delete]
    if alert.destroy
      redirect '/alerts'
    else
      "Error"
    end
  else
    redirect "/alerts/#{alert.id}/delete"
  end
end

get '/alerts/:id/delete' do
  @alert = Alert.find(params[:id])
  @title = "Delete Alert"
  erb :"alerts/delete"
end

post '/alerts/:id/acknowledge.?:format?' do
  @alert = Alert.find(params[:id])
  halt 403 unless @alert.uid = params[:uid]

  @alert.acknowledged_at = Time.now
  @alert.save

  if params[:format] =~ /^(twiml|xml)$/
    content_type 'text/xml'
    Twilio::TwiML::Response.new do |r|
      r.Say "The alert with ID #{@alert.id} has been acknowledged. Thank you and Goodbye!", voice: "woman"
    end.text
  else
    redirect "/alerts/#{@alert.id}"
  end
end

post '/alerts/:id.:format' do
  @alert = Alert.find(params[:id])
  halt 403 unless @alert.uid = params[:uid]
  if params[:format] =~ /^(twiml|xml)$/
    content_type 'text/xml'
    Twilio::TwiML::Response.new do |r|
      r.Say @alert.message, voice: "woman"
      r.Gather(numDigits: 1, action: "/alerts/#{@alert.id}/acknowledge.twiml?uid=#{@alert.uid}") do |g|
        g.Say "Please enter any key to acknowledge the message.", voice: "woman"
      end
      r.Say "We didn't receive any input. We will call you again. Goodbye!", voice: "woman"
    end.text
  else
    redirect "/alerts/#{@alert.id}"
  end
end

post '/alerts/:id/alert' do
  @alert = Alert.find(params[:id])
  @contact = Duty.find(1).contact

  twilio = TwilioApi.new(settings.account_sid, settings.auth_token, settings.from_number)
  twilio.call(@contact.phone, URI::join(settings.base_url, "/alerts/#{@alert.id}.twiml?uid=#{@alert.uid}"))
  twilio.sms(@contact.phone, @alert.message) if @contact.alert_by_sms == 1

  @alert.last_alert_at = Time.now
  @alert.save

  redirect "/alerts/#{@alert.id}"
end
