# Contacts Controller

get '/contacts.?:format?' do
  protected!
  if params[:format] == "json"
    content_type :json
    Onduty::Contact.all.only(:first_name, :last_name, :duty, :phone).asc(:last_name).map do |contact|
      {
        name: contact.name,
        duty: contact.duty_name,
        phone: contact.phone
      }
    end.to_json
  else
    @title = "Contacts"
    @contacts = Onduty::Contact.all.asc(:last_name)
    erb :"contacts/index"
  end
end

get '/contacts/new' do
  protected!
  @method = 'new'
  @title = "Create Contact"
  @contact = Onduty::Contact.new
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
      "Error during contact creation. Please review your input:"
    )
    flash[:danger] = message
    @method = 'new'
    @title = "Create Contact"
    erb :"/contacts/form"
  end
end

get '/contacts/:id' do
  protected!
  @contact = Onduty::Contact.find(params[:id])
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
  if params[:confirm_delete]
    if contact.destroy
      flash[:success] = "Successfuly deleted contact."
      redirect '/contacts'
    else
      flash[:danger] = "Error deleting contact."
    end
  else
    flash[:danger] = "Error deleting contact. Please confirm deletion."
    redirect "/contacts/#{contact.id}/delete"
  end
end

get '/contacts/:id/delete' do
  protected!
  @contact = Onduty::Contact.find(params[:id])
  @title = "Delete Contact"
  erb :"contacts/delete"
end
