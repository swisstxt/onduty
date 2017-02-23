# Duties Controller

post '/duties/:id/:contact_id?' do
  protected!

  Onduty::Contact.where(duty: params[:id]).update_all(duty: 0)
  contact = Onduty::Contact.find(params[:contact_id])
  contact.update(duty: params[:id])

  if Onduty::Notification.plugins.iclude? "SlackNotification"
    message = "#{contact.name} is on duty"
    message += " (#{Onduty::Duty.types[params[:id]]})"
    post_slack_message(message + ".")
  end

  flash[:success] = "Successfuly updated duty settings."
  redirect back
end
