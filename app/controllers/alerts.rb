# Alerts Controller

# Acknowledge alert (format: twiml & html)
route :get, :post, '/alerts/:id/acknowledge.?:format?' do
  @alert = Onduty::Alert.find(params[:id])
  halt 403 unless @alert.uid == params[:uid]

  ack = Onduty::Icinga2.new(
    api_path: settings.icinga2_api_path,
    user: settings.icinga2_user,
    password: settings.icinga2_password
  ).acknowledge_services(@alert.services)
  if ack[:acknowledged] == 1
    @alert.acknowledge!
  end

  if params[:format] =~ /^(twiml|xml)$/
    content_type 'text/xml'
    Twilio::TwiML::Response.new do |r|
      r.Say ack[:message], voice: "woman"
      if @alert.acknowledged?
        r.Say "Thank you and Goodbye!", voice: "woman"
      else
        r.Say "Sorry, we are unable to acknowledge the issue.", voice: "woman"
      end
    end.text
  elsif params[:format] == "html"
    content_type 'text/html'
    ack[:message]
  else
    if @alert.acknowledged?
      flash[:success] = ack[:message]
    else
      flash[:danger] = ack[:message]
    end
    erb :"alerts/show"
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

  time = if params[:days] == 'all'
    0
  else
    params[:days].to_i > 0 ? days_ago(params[:days]) : days_ago(7)
  end

  @alerts =  if params[:format] == "json"
    Onduty::Alert.created_after(time)
  else
    Onduty::Alert.created_after(time).page(params[:page]).per(10)
  end

  session[:filter_ack] = params[:ack]
  @alerts = if params[:ack] == 'true'
    @alerts.acknowledged
  elsif params[:ack] == 'false'
    @alerts.unacknowledged
  else
    @alerts.order(created_at: :desc)
  end

  if params[:format] == "json"
    content_type :json
    @alerts.to_json
  else
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
    alert = Onduty::Alert.find_or_create_by(
      name: payload['alert']['name'],
      acknowledged_at: nil
    )
    payload['alert']['services'].each do |srv|
      alert.services.find_or_initialize_by(
        name: srv["name"],
        host: srv["host"]
      )
    end
    if payload[:group]
      alert.group = Onduty::Group.where(name: payload[:group]).first || nil
    else
      alert.group = Onduty::Group.asc(:position).first || nil
    end
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
  @alert = Onduty::Alert.find(params[:id])
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
