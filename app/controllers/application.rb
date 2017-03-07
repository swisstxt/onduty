# Application Controller

configure do
  enable :sessions
  set :session_secret, settings.session_secret || SecureRandom.hex(64)
  use Rack::Flash, sweep: true
  register Sinatra::MultiRoute
  Mongoid.load!(Onduty::Config.new.mongoid_config)
end

get '/' do
  @contacts_count = Onduty::Contact.all.size
  @open_alerts    = Onduty::Alert.in(acknowledged_at: nil).all.size
  erb :index
end

not_found do
  @title = "404"
  erb :'404'
end
