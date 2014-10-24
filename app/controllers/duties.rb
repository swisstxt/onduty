#################################
# Duties
#

post '/duties/:id/:contact_id?' do
  Duty.where(contact_id: params[:contact_id]).update_all(contact_id: nil)
  Duty.find(params[:id]).update(contact_id: params[:contact_id])
  redirect back
end
