# Alerts Controller

post '/alerts/acknowledge-old' do
  protected!
  Onduty::Alert.unacknowledged.created_before(
    Time.now - 24.hours
  ).update_all(acknowledged_at: Time.now)
  flash[:success] = "Alerts older than 24 hours have been acknowledged"
  redirect back
end

# Acknowledge alert (format: twiml & html)
route :get, :post, '/alerts/:id/acknowledge.?:format?' do
  @alert = Onduty::Alert.find(params[:id])
  halt 403 unless @alert.uid == params[:uid]

  ack = nil

  if @alert.acknowledged?
    if params[:format] =~ /^(twiml|xml)$/
      content_type 'text/xml'
      Twilio::TwiML::VoiceResponse.new do |r|
        r.say "This alert was already acknowledged.", voice: "woman"
        r.say "Thank you and Goodbye!", voice: "woman"
      end.to_s
    else
      flash[:success] = "This alert was already acknowledged."
      redirect "/alerts/#{@alert.id}"
    end
  else
    if settings.icinga2_api_path
      ack = Onduty::Icinga2.instance.acknowledge_services(@alert.services)
    else
      ack = {
        acknowledged: 1,
        message: "The alert has been successfully acknowledeged."
      }
    end

    if ack[:acknowledged] == 1
      @alert.acknowledge!
    end

    if params[:format] =~ /^(twiml|xml)$/
      content_type 'text/xml'
      Twilio::TwiML::VoiceResponse.new do |r|
        r.say ack[:message], voice: "woman"
        r.say "Thank you and Goodbye!", voice: "woman"
      end.to_s
    else
      if ack[:acknowledged] == 1
        flash[:success] = ack[:message]
      else
        flash[:danger] = ack[:message]
      end
      if request.referrer
        redirect back
      else
        redirect "/alerts/#{@alert.id}"
      end
    end
  end
end

# Access the alert and respond with twiml format
post '/alerts/:id.twiml' do
  @alert = Onduty::Alert.find(params[:id])
  halt 403 unless @alert.uid = params[:uid]

  alert_message = @alert.shortened_name(settings.alert_shortener_regex)

  content_type 'text/xml'
  Twilio::TwiML::VoiceResponse.new do |r|
    r.say("Hello! Onduty here to alert.", voice: "woman")
    r.say(alert_message, voice: "woman", loop: 2)
    unless @alert.acknowledged?
      r.gather(
        numDigits: 1,
        action: "/alerts/#{@alert.id}/acknowledge.twiml?uid=#{@alert.uid}"
      ) do |g|
        g.say "Please enter any key to acknowledge the message.", voice: "woman"
      end
      r.say(
        "We didn't receive any input. We will call you again. Goodbye!",
        voice: "woman"
      )
    end
  end.to_s
end

# Trigger notifications for a certain alert
post '/alerts/:id/alert/?:duty_type?' do
  protected!
  @alert = Onduty::Alert.find(params[:id])
  options = params[:duty_type] ? {duty_type: params[:duty_type].to_i} : {}
  options[:force] = true if params[:force] == '1'
  if Onduty::Notification.notify_all(@alert, options)
    flash[:success] = "Successfuly alerted."
  else
    flash[:danger] = "There was a problem notifying onduty contacts."
  end
  redirect "/alerts/#{@alert.id}"
end

# List all alerts
get '/alerts.?:format?' do
  protected!
  @title = "Alerts"

  session[:filter_days] = params[:days]
  time = if params[:days] == "all"
    0
  elsif params[:days].to_i > 0
    days_ago(params[:days])
  else
    days_ago(7)
  end

  session[:group_id] = params[:group_id]
  @alerts = if params[:group_id] && params[:group_id] != "all"
    Onduty::Alert.where(group_id: params[:group_id]).created_after(time).order(created_at: :desc)
  else
    Onduty::Alert.created_after(time).order(created_at: :desc)
  end

  case (session[:filter_ack] = params[:ack])
  when "true"
    @alerts = @alerts.acknowledged
  when "false"
    @alerts = @alerts.unacknowledged
  end

  if params[:format] == "json"
    content_type :json
    @alerts.to_json
  else
    @alerts = @alerts.page(params[:page]).per(10)
    erb :"alerts/index"
  end
end

get '/alerts/new' do
  protected!
  @method = 'new'
  @title = "Create Alert"
  @alert = Onduty::Alert.new
  erb :"alerts/form"
end

# Create a new alert (JSON)
post '/alerts/new.json' do
  protected!
  content_type :json
  begin
    payload = JSON.parse(request.body.read)
    alert = Onduty::Alert.where(
      :created_at.gte => Time.now - settings.alert_threshold
    ).find_or_create_by(
      name: payload['alert']['name'],
      acknowledged_at: nil
    )
    payload['alert']['services'].each do |srv|
      alert.services.find_or_initialize_by(
        name: srv["name"],
        host: srv["host"]
      )
    end
    alert.group = Onduty::Group.find_or_default(payload['alert']['group'])
    if alert.save
      options = { duty_type: 1 }
      options[:force] = true if payload['force']
      Onduty::Notification.notify_all(alert, options)
      alert.to_json
    else
      status 400
      { errors: alert.errors.full_messages }.to_json
    end
  rescue => e
    status 400
    { errors: [e.message] }.to_json
  end
end

# Create a new alert (html)
post '/alerts/new' do
  protected!
  @alert = Onduty::Alert.create(params[:alert])
  if @alert.save
    message = "Successfuly created "
    options = { duty_type: 1 }
    options[:force] = true if params[:force]
    Onduty::Notification.notify_all(@alert, options)
    flash[:success] = "#{message} alert."
    redirect "/alerts/#{@alert.id}"
  else
    message = form_error_message(
      @alert,
      title: "Error during alert creation. Please review your input:"
    )
    flash[:danger] = message
    redirect '/alerts/new'
  end
end

get '/alerts/:id' do
  protected!
  begin
    @alert = Onduty::Alert.find(params[:id])
    @icinga = Onduty::Icinga2.instance
  rescue Mongoid::Errors::DocumentNotFound
    halt 404
  end
  @title = "Alert #{@alert.name}"
  erb :"alerts/show"
end

delete '/alerts/:id/delete' do
  protected!
  alert = Onduty::Alert.find(params[:id])
  if alert.destroy
    flash[:success] = "Successfuly deleted alert."
    redirect to("/alerts#{alerts_link_filter}")
  else
    flash[:danger] = "Error deleting alert."
    redirect to("/alerts/#{params[:id]}")
  end
end

get '/alerts/:id/delete' do
  protected!
  @alert = Onduty::Alert.find(params[:id])
  @title = "Delete Alert"
  erb :"alerts/delete"
end
