# Contacts Controller

get '/contacts' do
  protected!
  @title = "Contacts"
  @contacts = Onduty::Contact.all.order(:last_name)
  @duties = Onduty::Duty.all
  erb :"contacts/index"
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
  contact = Onduty::Contact.new(params[:contact])
  if contact.save
    flash[:success] = "Successfuly created contact."
    redirect "/contacts/#{contact.id}"
  else
    flash[:danger] = "Error during contact creation. Please submit all required values."
    redirect '/contacts/new'
  end
end

get '/contacts/:id' do
  protected!
  @contact = Onduty::Contact.find(params[:id])
  @duty = Onduty::Duty.where(contact_id: params[:id]).first
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
    flash[:danger] = "Error editing contact."
    redirect back
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
