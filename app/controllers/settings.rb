# Plugins Controller

get '/settings' do
  protected!
  @title = "Plugins"
  @plugins = Onduty::Notification::AVAILABLE_PLUGINS
  @settings = ENV.select do |k, _|
    k.to_s.match(/^ONDUTY_.*/)
  end
  erb :"settings/index"
end
