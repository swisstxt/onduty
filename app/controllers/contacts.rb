# Contacts Controller

get '/contacts.?:format?' do
  protected!
  filter = {}
  if params[:group] && params[:group] != "all"
    filter[:group_id] = params[:group]
  end
  if params[:group_name] && params[:group_name] != "all"
    group = Onduty::Group.where(name: params[:group_name]).only(:id).first
    filter[:group_id] = group ? group.id : 0
  end
  if params[:duty] && params[:duty] != "all"
    filter[:duty] = Onduty::Duty.types.invert[params[:duty]]
  end
  if params[:format] == "json"
    content_type :json
    Onduty::Contact.where(filter).only(:first_name, :last_name, :duty, :phone, :group).asc(:last_name).map do |contact|
      {
        name: contact.name,
        group: (contact.group ? contact.group.name : ""),
        duty: contact.duty,
        duty_name: contact.duty_name,
        phone: contact.phone
      }
    end.to_json
  else
    @title = "Contacts"
    @contacts = Onduty::Contact.where(filter).asc(:last_name)
    erb :"contacts/index"
  end
end

get '/contacts/new' do
  protected!
  @method = 'new'
  @title = "Create Contact"
  @contact = Onduty::Contact.new
  @contact.group = Onduty::Group.first_or_default
  erb :"contacts/form"
end

post '/contacts/new' do
  protected!
  @contact = Onduty::Contact.new(params[:contact])
  if @contact.save
    flash[:success] = "Successfuly created contact."
    redirect "/contacts/#{@contact.id}"
  else
    message = form_error_message(
      @contact,
      title: "Error during contact creation. Please review your input:"
    )
    flash[:danger] = message
    @method = 'new'
    @title = "Create Contact"
    erb :"/contacts/form"
  end
end

get '/contacts/:id' do
  protected!
  begin
    @contact = Onduty::Contact.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    halt 404
  end
  @title = @contact.name
  erb :"contacts/show"
end

get '/contacts/:id/edit' do
  protected!
  @method = "#{params[:id]}/edit"
  @contact = Onduty::Contact.find(params[:id])
  @title = "Edit Contact"
  erb :"contacts/form"
end

post '/contacts/:id/edit' do
  protected!
  @contact = Onduty::Contact.find(params[:id])
  params[:contact][:alert_by_email] = params[:contact][:alert_by_email] || 0
  params[:contact][:alert_by_sms] = params[:contact][:alert_by_sms] || 0
  if @contact.update(params[:contact])
    flash[:success] = "Successfuly edited contact."
    redirect "/contacts/#{@contact.id}"
  else
    message = form_error_message(
      @contact,
      title: "Error editing contact:"
    )
    flash[:danger] = message
    @title = "Edit Contact"
    @method = "#{params[:id]}/edit"
    erb :"contacts/form"
  end
end

delete '/contacts/:id/delete' do
  protected!
  contact = Onduty::Contact.find(params[:id])
  if contact.destroy
    flash[:success] = "Successfuly deleted contact."
    redirect '/contacts'
  else
    flash[:danger] = "Error deleting contact."
  end
end

get '/contacts/:id/delete' do
  protected!
  @contact = Onduty::Contact.find(params[:id])
  @title = "Delete Contact"
  erb :"contacts/delete"
end
