module Onduty
  class MailNotification < Notification
    require 'mail'

    def name
      "Onduty Mail Notification"
    end

    def trigger
      if @contact.email && @contact.alert_by_email == 1
        from = @settings.email_sender || 'onduty@onduty'
        body_text = Erubis::Eruby.new(
          File.read(File.join(File.dirname(__FILE__), 'mail_notification.erb'))
        ).result(
          alert: @alert,
          contact: @contact,
          acknowledge_url: acknowledge_url(html_link: true)
        )
        if smtp_options = @settings.smtp_options
          Mail.defaults do
            delivery_method :smtp, smtp_options
          end
        end
        Mail.deliver do
          from     from
          to        @contact.email
          subject  "[Alert #{@alert.id}] Alert from onduty"
          body     body_text
        end
        logger.info "Sent alert email with ID #{@alert.id} to #{@contact.name} (#{@contact.group ? @contact.group.name : '-'})."
      end
    rescue => e
      logger.error "Error sending email: #{e.message}"
      if ENV['APP_ENV'] == 'development'
        logger.info "Backtrace: #{e.backtrace}"
      end
    end

  end
end
