# Duties Controller

post '/duties/:id/:contact_id?' do
  Onduty::Duty.where(contact_id: params[:contact_id]).update_all(contact_id: nil)
  Onduty::Duty.find(params[:id]).update(contact_id: params[:contact_id])
  flash[:success] = "Successfuly updated duty settings."
  redirect back
end
