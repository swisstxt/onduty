# Stats Controller

get '/stats' do
  protected!
  @since_days = params[:days] ? params[:days].to_i : 30
  @alert_count_limit = params[:alert_count] ? params[:alert_count].to_i : settings.alert_limit
  @stats = Onduty::Stats.new(since_days: @since_days, alert_count_limit: @alert_count_limit)
  @groups = Onduty::Group.all
  erb :"stats/index"
end
