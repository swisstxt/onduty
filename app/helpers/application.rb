helpers do
  def protected!
    unless settings.respond_to?(:admin_user) &&
      settings.respond_to?(:admin_password)
     return
    end
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Access Restricted"'
    halt 401, "Not authorized\n"
  end

  def post_slack_message(message)
    if settings.slack_api_token && settings.slack_channel
      begin
        Onduty::SlackHelper.post_message(
          message,
          settings.slack_channel,
          settings.slack_api_token
        )
      rescue => e
        puts "ERROR: Can't create Slack message - #{e.message}"
      end
    else
      puts "WARNING: Unsuficient credentials for posting Slack message."
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials &&
      @auth.credentials == [settings.admin_user, settings.admin_password]
  rescue
    false
  end

  def paginate(collection, base_path, options = {})
    @collection = collection
    @path = base_path
    erb :pagination, options.merge!(layout: false)
  end

  def alerts_link_filter
    filter = []
    if session['filter_days']
      filter << "days=#{session['filter_days']}"
    end
    if session['filter_ack']
      filter << "ack=#{session['filter_ack']}"
    end
    filter.size > 0 ? "?" + filter.join('&') : ''
  end

  def status_badge(status)
    case status
      when 1 then 'danger'
      when 2 then 'primary'
      else 'default'
    end
  end

  def merge_query_string(args)
    query = params.merge(args.keys[0].to_s => args.values[0])
    query.select{|k,_| k != "format"}.map{|k,v| "#{k}=#{v}"}.join('&')
  end

  def h_time(time)
    time.strftime("%d.%m.%Y %T") rescue time
  end

  def days_ago(x)
    Time.now - x.to_i * 3600 * 24
  end

  def formated_phone(number)
    "#{number[0..2]} #{number[3..4]} #{number[5..7]} #{number[8..9]} #{number[10..-1]}" rescue number
  end

  def form_error_message(model, options = {})
    title = options[:title] || ""
    message = [title]
    if model.errors.size > 0
      message << %w(<br> <ul>)
      message << model.errors.full_messages.map {|msg| "<li>#{msg}</li>"}
      message << "</ul>"
    end
    message.join("\n")
  end
end
