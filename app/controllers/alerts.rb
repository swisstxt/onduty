# Alerts Controller

route :get, :post, '/alerts/:id/acknowledge.?:format?' do
  @alert = Onduty::Alert.find(params[:id])
  halt 403 unless @alert.uid = params[:uid]

  success_message = "The alert has been successfully acknowledeged."
  failure_message = "Error during alert acknowledgment."

  if ack = Onduty::Icinga.new.acknowledge_service(
    @alert.host, @alert.service, { comment: "acknowledged by onduty" }
  )
    @alert.acknowledged_at = ack
    @alert.save
  end

  if params[:format] =~ /^(twiml|xml)$/
    content_type 'text/xml'
    Twilio::TwiML::Response.new do |r|
      if ack
        r.Say success_message, voice: "woman"
        r.Say "Thank you and Goodbye!", voice: "woman"
      else
        r.Say failure_message, voice: "woman"
      end
    end.text
  elsif params[:format] == "html"
    content_type 'text/html'
    ack ? success_message : failure_message
  else
    if ack
      flash[:success] = success_message
    else
      flash[:danger] = failure_message
    end
    redirect "/alerts/#{@alert.id}"
  end
end

# Access the alert and respond with twiml format
post '/alerts/:id.twiml' do
  @alert = Onduty::Alert.find(params[:id])
  halt 403 unless @alert.uid = params[:uid]
  content_type 'text/xml'
  Twilio::TwiML::Response.new do |r|
    r.Say(@alert.message, voice: "woman", loop: 2)
    r.Gather(
      numDigits: 1,
      action: "/alerts/#{@alert.id}/acknowledge.twiml?uid=#{@alert.uid}"
    ) do |g|
      g.Say "Please enter any key to acknowledge the message.", voice: "woman"
    end
    r.Say(
      "We didn't receive any input. We will call you again. Goodbye!",
      voice: "woman"
    )
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

  session[:filter_days] = params[:days]
  @alerts = if params[:days] == 'all'
    Onduty::Alert.all
  elsif params[:days].to_i > 0
    Onduty::Alert.created_after(days_ago(params[:days]))
  else
    Onduty::Alert.created_after(days_ago(7))
  end

  session[:filter_ack] = params[:ack]
  @alerts = if params[:ack] == 'true'
    @alerts.acknowledged
  elsif params[:ack] == 'false'
    @alerts.unacknowledged
  else
    @alerts.order(created_at: :desc)
  end

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
  @title = "Alert #{@alert.service}"
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
