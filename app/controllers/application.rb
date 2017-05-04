# Application Controller

configure do
  enable :sessions
  set :session_secret, settings.session_secret || SecureRandom.hex(64)
  use Rack::Flash, sweep: true
  register Sinatra::MultiRoute
  Mongoid.load!(Onduty::Config.new.mongoid_config)
end

get '/' do
  redirect to('/alerts')
end

not_found do
  @title = "404"
  erb :'404'
end
