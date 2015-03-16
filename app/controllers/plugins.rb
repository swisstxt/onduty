# Plugins Controller

get '/plugins' do
  protected!
  @title = "Plugins"
  @plugins = Onduty::Notification::PLUGINS
  erb :"plugins/index"
end
