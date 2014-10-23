helpers do
  def status_badge(status)
    case status
      when 1 then 'danger'
      when 2 then 'primary'
      else 'default'
    end
  end

  def h_time(time)
    time.strftime("%d.%m.%Y %T") rescue time
  end

  def days_ago(x)
    Time.now - x.to_i * 3600 * 24
  end
end
