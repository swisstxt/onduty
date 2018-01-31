# Duties Controller

post '/duties/' do
  protected!
  begin
    contact = Onduty::Contact.find(params[:contact_id])
    duty_type = params[:id].to_i
    Onduty::Contact.where(
      duty: duty_type,
      group_id: contact.group_id
    ).update_all(duty: 0)
    contact.update(duty: duty_type)
    if Onduty::Notification.plugins.include? "SlackNotification"
      msg = ":+1: *#{contact.name}* "
      msg += "(Group: {contact.group.name}) " if contact.group
      msg += "is on duty."
      post_slack_message(msg)
    end
    flash[:success] = "Successfuly updated duty settings."
  rescue
    flash[:danger] = "ERROR: Couldn't associate duty with new contact: Contact not found."
  end
  redirect back
end
