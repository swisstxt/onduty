
get '/debug' do
  protected!
  @title = "Debug"
  @settings = {}
  ENV.each do |k, v|
    if k.to_s.match(/^ONDUTY_.*/)
      if k.to_s.match(/(SECRET|PASSWORD)/)
        v = v == '' ? '' : '******'
      end
      @settings[k] = v
    end
  end
  erb :"debug/index"
end
