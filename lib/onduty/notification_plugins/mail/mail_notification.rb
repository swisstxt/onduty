module Onduty
  class MailNotification < Notification
    require 'pony'

    def name
      "Onduty Mail Notification"
    end

    def valid_configuration?
      @contact.email && @settings.smtp_options
    end

    def trigger
      if @contact.email && @contact.alert_by_email == 1
        from = @settings.email_sender ? @settings.email_sender : 'onduty@onduty'
        body = Erubis::Eruby.new(
          File.read(File.join(File.dirname(__FILE__), 'mail_notification.erb'))
        ).result(alert: @alert, contact: @contact, acknowledge_url: acknowledge_url)
        Pony.mail({
          from:    from,
          to:      @contact.email,
          subject: "[Alert #{@alert_id}] Alert from onduty" ,
          body:    body,
          via:     :smtp,
          via_options: @settings.smtp_options
        })
        logger.info "Sent alert email with ID #{@alert_id} to #{@contact.name}."
      end
    rescue => e
      logger.error "Error sending email: #{e.message}"
    end

  end
end
