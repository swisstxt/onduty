# Groups Controller

get '/groups.?:format?' do
  protected!
  if params[:format] == "json"
    content_type :json
    Onduty::Group.all.to_json
  else
    @title = "Groups"
    @groups = Onduty::Group.all.asc(:position).page(params[:page]).per(10)
    erb :"groups/index"
  end
end

get '/groups/new' do
  protected!
  @method = 'new'
  @title = "Create Group"
  @group = Onduty::Group.new
  erb :"groups/form"
end

post '/groups/new' do
  protected!
  @group = Onduty::Group.new(params[:group])
  if @group.save
    flash[:success] = "Successfuly created group."
    redirect "/groups/#{@group.id}"
  else
    message = form_error_message(
      @group,
      title: "Error during group creation. Please review your input:"
    )
    flash[:danger] = message
    @method = 'new'
    @title = "Create Group"
    erb :"/groups/form"
  end
end

get '/groups/:id' do
  protected!
  begin
    @group = Onduty::Group.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    halt 404
  end
  @title = @group.name
  erb :"groups/show"
end

get '/groups/:id/edit' do
  protected!
  @method = "#{params[:id]}/edit"
  @group = Onduty::Group.find(params[:id])
  @title = "Edit Group"
  erb :"groups/form"
end

post '/groups/:id/edit' do
  protected!
  @group = Onduty::Group.find(params[:id])
  if @group.update(params[:group])
    flash[:success] = "Successfuly edited group."
    redirect "/groups/#{@group.id}"
  else
    message = form_error_message(
      @group,
      title: "Error editing group:"
    )
    flash[:danger] = message
    @title = "Edit Group"
    @method = "#{params[:id]}/edit"
    erb :"groups/form"
  end
end

delete '/groups/:id/delete' do
  protected!
  group = Onduty::Group.find(params[:id])
  if group.destroy
    flash[:success] = "Successfuly deleted group."
    redirect '/groups'
  else
    flash[:danger] = "Error deleting group."
  end
end

get '/groups/:id/delete' do
  protected!
  @group = Onduty::Group.find(params[:id])
  @title = "Delete Group"
  erb :"groups/delete"
end

post '/groups/:id/reposition/' do
  group = Onduty::Group.find(params[:id])
  position = case params[:value]
  when "+1"
    group.position - 1
  when "-1"
    group.position + 1
  else
    params[:value].to_i
  end
  group.update_attributes!(position: position)
  redirect back
end
