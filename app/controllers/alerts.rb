# Alerts Controller

route :get, :post, '/alerts/:id/acknowledge.?:format?' do
  @alert = Onduty::Alert.find(params[:id])
  halt 403 unless @alert.uid = params[:uid]
  icinga_cmd = if settings.respond_to?(:icinga_cmd_path)
    settings.icinga_cmd_path
  else
    nil
  end
  @alert.acknowledge(icinga_cmd)
  @alert.save
  if params[:format] =~ /^(twiml|xml)$/
    content_type 'text/xml'
    Twilio::TwiML::Response.new do |r|
      r.Say "The alert with ID #{@alert.id} has been acknowledged. Thank you and Goodbye!", voice: "woman"
    end.text
  else
    flash[:success] = "Successfuly acknowledeged alert."
    redirect "/alerts/#{@alert.id}"
  end
end

# Access the alert and respond with twiml format
post '/alerts/:id.twiml' do
  @alert = Onduty::Alert.find(params[:id])
  halt 403 unless @alert.uid = params[:uid]
  content_type 'text/xml'
  Twilio::TwiML::Response.new do |r|
    r.Say @alert.message, voice: "woman"
    r.Gather(numDigits: 1, action: "/alerts/#{@alert.id}/acknowledge.twiml?uid=#{@alert.uid}") do |g|
      g.Say "Please enter any key to acknowledge the message.", voice: "woman"
    end
    r.Say "We didn't receive any input. We will call you again. Goodbye!", voice: "woman"
  end.text
end

post '/alerts/:id/alert/?:duty_type?' do
  protected!
  @alert = Onduty::Alert.find(params[:id])
  options = params[:duty_type] ? {duty_type: params[:duty_type].to_i} : {}
  if Onduty::Notification.new(@alert.id, options).notify
    flash[:success] = "Successfuly alerted."
  else
    flash[:danger] = "There was a problem notifying onduty contacts."
  end
  redirect "/alerts/#{@alert.id}"
end

get '/alerts' do
  protected!
  @title = "Alerts"
  @alerts = if params[:days] == 'all'
    Onduty::Alert.all
  elsif params[:days].to_i > 0
    Onduty::Alert.created_after(days_ago(params[:days]))
  else
    Onduty::Alert.created_after(days_ago(2))
  end
  @alerts = @alerts.acknowledged if params[:acknowledged] == 'true'
  @alerts = @alerts.unacknowledged if params[:acknowledged] == 'false'
  @alerts = @alerts.order(created_at: :desc)
  erb :"alerts/index"
end

get '/alerts/new' do
  protected!
  @method = 'new'
  @title = "Create Alert"
  @alert = Onduty::Alert.new
  erb :"alerts/form"
end

post '/alerts/new' do
  protected!
  alert = Onduty::Alert.new(params[:alert])
  if alert.save
    flash[:success] = "Successfuly created alert."
    redirect "/alerts/#{alert.id}"
  else
    flash[:danger] = "Error during alert creation. Please submit all required values."
    redirect '/alerts/new'
  end
end

get '/alerts/:id' do
  protected!
  @alert = Onduty::Alert.find(params[:id])
  @title = "Alert #{@alert.id}"
  erb :"alerts/show"
end

delete '/alerts/:id/delete' do
  protected!
  alert = Onduty::Alert.find(params[:id])
  if params[:confirm_delete]
    if alert.destroy
      flash[:success] = "Successfuly deleted alert."
      redirect '/alerts'
    else
      flash[:danger] = "Error deleting alert."
    end
  else
    flash[:danger] = "Error deleting alert. Please confirm deletion."
    redirect "/alerts/#{alert.id}/delete"
  end
end

get '/alerts/:id/delete' do
  protected!
  @alert = Onduty::Alert.find(params[:id])
  @title = "Delete Alert"
  erb :"alerts/delete"
end
