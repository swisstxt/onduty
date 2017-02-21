helpers do
  def protected!
    unless settings.respond_to?(:admin_user) && settings.respond_to?(:admin_password)
     return
    end
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials &&
      @auth.credentials == [settings.admin_user, settings.admin_password]
  rescue
    true
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
    query.map{|k,v| "#{k}=#{v}"}.join('&')
  end

  def h_time(time)
    time.strftime("%d.%m.%Y %T") rescue time
  end

  def days_ago(x)
    Time.now - x.to_i * 3600 * 24
  end
end
