# Application Controller

enable :sessions
set :session_secret, settings.session_secret || SecureRandom.uuid
use Rack::Flash, sweep: true
register Sinatra::MultiRoute

get '/' do
  redirect '/contacts'
end

not_found do
  @text = "That page doesn't exist"
  @title = "404"
  erb :'404'
end
