# Application Controller

configure do
  enable :sessions
  set :session_secret, settings.session_secret || SecureRandom.uuid
  use Rack::Flash, sweep: true
  register Sinatra::MultiRoute
  puts "load mongoid"
  puts Mongoid.load!("config/mongoid.yml")
end

get '/' do
  redirect '/contacts'
end

not_found do
  @text = "That page doesn't exist"
  @title = "404"
  erb :'404'
end
