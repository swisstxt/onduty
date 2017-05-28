# Application Controller

configure do
  enable :sessions
  set :session_secret, settings.session_secret || SecureRandom.hex(64)
  use Rack::Flash, sweep: true
  register Sinatra::MultiRoute
  Mongoid.load! Onduty::Config.new.mongoid_config
  set :environment,   (ENV["RACK_ENV"] || :development).to_sym
  set :root,          File.join(File.dirname(__FILE__), '../../', 'app')
  set :public_folder, File.join(File.dirname(__FILE__), '../../', 'public')

  # set :layout,  true
  # set :erb, layout_options: { layout: 'layout' }
  # register Kaminari::Helpers::SinatraHelpers
end

get '/' do
  redirect to('/alerts')
end

not_found do
  @title = "404"
  erb :'404'
end
