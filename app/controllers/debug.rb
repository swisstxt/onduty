
get '/debug' do
  protected!
  @title = "Debug"
  @onduty_env = {}
  ENV.each do |k, v|
    if k.to_s.match(/^ONDUTY_.*/)
      if k.to_s.match(/(SECRET|PASSWORD)/)
        v = v == '' ? '' : '******'
      end
      @onduty_env[k] = v
    end
  end
  @settings = {}
  Onduty::Config.instance.settings.map do |k, v|
    if k.to_s.match(/(secret|password)/)
      @settings[k] = v == '' ? '' : '******'
    else
      @settings[k] = v
    end
  end
  erb :"debug/index"
end
