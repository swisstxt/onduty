# Plugins Controller

get '/plugins' do
  protected!
  @title = "Plugins"
  @plugins = Onduty::Notification::AVAILABLE_PLUGINS
  erb :"plugins/index"
end
