#################################
# Contacts
#

get '/contacts' do
  @title = "Contacts"
  @contacts = Contact.all.order(:last_name)
  @duties = Duty.all
  erb :"contacts/index"
end

get '/contacts/new' do
  @method = 'new'
  @title = "Create Contact"
  @contact = Contact.new
  erb :"contacts/form"
end

post '/contacts/new' do
  contact = Contact.new(params[:contact])
  if contact.save
    redirect "/contacts/#{contact.id}"
  else
    redirect '/contacts/new'
  end
end

get '/contacts/:id' do
  @contact = Contact.find(params[:id])
  @title = @contact.name
  erb :"contacts/show"
end

get '/contacts/:id/edit' do
  @method = "#{params[:id]}/edit"
  @contact = Contact.find(params[:id])
  @title = "Edit Contact"
  erb :"contacts/form"
end

post '/contacts/:id/edit' do
  @contact = Contact.find(params[:id])
  if @contact.update(params[:contact])
    redirect "/contacts/#{@contact.id}"
  else
    'Error'
  end
end

delete '/contacts/:id/delete' do
  contact = Contact.find(params[:id])
  if params[:confirm_delete]
    if contact.destroy
      redirect '/contacts'
    else
      "Error"
    end
  else
    redirect "/contacts/#{contact.id}/delete"
  end
end

get '/contacts/:id/delete' do
  @contact = Contact.find(params[:id])
  @title = "Delete Contact"
  erb :"contacts/delete"
end
