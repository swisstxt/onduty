# Application Controller

enable :sessions
set :session_secret, settings.session_secret || SecureRandom.uuid 
use Rack::Flash, sweep: true
register Sinatra::MultiRoute

# activate rack-cache and contrib in production
configure :production do
  use Rack::Cache,
    :verbose => true,
    :metastore => "file:cache/meta",
    :entitystore => "file:cache/body"
  use Rack::StaticCache,
    :urls => ['/css', '/img', '/js'],
    :root => "public",
    :duration => 1
end

before do
  headers "Content-Type" => "text/html; charset=utf-8"
  response["Cache-Control"] = "max-age=300, public"
end

get '/' do
  redirect '/contacts'
end

not_found do
  @text = "That page doesn't exist"
  @title = "404"
  erb :'404'
end
