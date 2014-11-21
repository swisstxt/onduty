# Duties Controller

post '/duties/:id/:contact_id?' do
  protected!
  Onduty::Contact.where(duty: params[:id]).update_all(duty: 0)
  Onduty::Contact.find(params[:contact_id]).update(duty: params[:id])
  flash[:success] = "Successfuly updated duty settings."
  redirect back
end
