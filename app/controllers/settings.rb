# Plugins Controller

get '/settings' do
  protected!
  @title = "Plugins"
  @plugins = Onduty::Notification::AVAILABLE_PLUGINS
  erb :"settings/index"
end
