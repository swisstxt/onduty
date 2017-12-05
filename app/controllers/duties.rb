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
      post_slack_message(
        ":+1: *#{contact.name}* (#{contact.group ? contact.group.name : ''}) is on duty (#{Onduty::Duty.types[duty_type]} contact)."
      )
    end
    flash[:success] = "Successfuly updated duty settings."
  rescue
    flash[:danger] = "ERROR: Couldn't associate duty with new contact: Contact not found."
  end
  redirect back
end
