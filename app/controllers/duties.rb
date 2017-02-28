# Duties Controller

post '/duties/:id/:contact_id?' do
  protected!
  duty_type = params[:id].to_i
  Onduty::Contact.where(duty: duty_type).update_all(duty: 0)

  begin
    contact = Onduty::Contact.find(params[:contact_id])
    contact.update(duty: duty_type)
    if Onduty::Notification.plugins.include? "SlackNotification"
      post_slack_message(
        ":+1: *#{contact.name}* is on duty (#{Onduty::Duty.types[duty_type]} contact)."
      )
    end
    flash[:success] = "Successfuly updated duty settings."
  rescue
    flash[:danger] = "ERROR: Couldn't associate duty with new contact: Contact not found."
  end
  @title = "Contacts"
  @contacts = Onduty::Contact.all.asc(:last_name)
  erb :"contacts/index"
end
