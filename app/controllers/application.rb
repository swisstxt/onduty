# Application Controller

configure do
  enable :sessions
  set :session_secret, settings.session_secret
  use Rack::Flash, sweep: true
  register Sinatra::MultiRoute
  set :environment,   (ENV["APP_ENV"] || :development).to_sym
  set :root,          File.join(File.dirname(__FILE__), '../../', 'app')
  set :public_folder, File.join(File.dirname(__FILE__), '../../', 'public')
  Mongoid.load! Onduty::Config.new.mongoid_config
end

get '/' do
  protected!
  @since_days = params[:days] ? params[:days].to_i : 30
  @alert_count_limit = params[:alert_count] ? params[:alert_count].to_i : settings.alert_limit
  @stats = Onduty::Stats.new(since_days: @since_days, alert_count_limit: @alert_count_limit)
  @groups = Onduty::Group.all
  erb :"stats"
end

not_found do
  erb :"404"
end
