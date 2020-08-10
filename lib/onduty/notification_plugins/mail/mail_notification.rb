module Onduty
  class MailNotification < Notification

    require 'mail'

    def name
      "Onduty Mail Notification"
    end

    def trigger
      if @contact.email && @contact.alert_by_email == 1
        set_mail_delivery_method
        build_mail.deliver!

        logger.info "Sent alert email with ID #{@alert.id} to #{@contact.name} (#{@contact.group ? @contact.group.name : '-'})."
      else
        logger.info "Skipping alert email for alert with ID #{@alert.id}"
      end
    rescue => e
      logger.error "Error sending email: #{e.message}"
      if ENV['APP_ENV'] == 'development'
        logger.info "Backtrace: #{e.backtrace}"
      end
    end

    private

    def build_mail
      from = @settings.email_sender || 'onduty@onduty'

      mail = Mail.new
      mail.from = from
      mail.to = @contact.email
      mail.subject = mail_subject
      mail.body = mail_body

      mail
    end

    def mail_subject
      if @alert.group
        "[Onduty - #{@alert.group.name}] #{@alert.name}"
      else
        "[Onduty] #{@alert.name}"
      end
    end

    def mail_body
      body_text = Erubis::Eruby.new(
        File.read(File.join(File.dirname(__FILE__), 'mail_notification.erb'))
      ).result(
        alert: @alert,
        contact: @contact,
        acknowledge_url: acknowledge_url(html_link: true)
      )
    end

    def set_mail_delivery_method
      if smtp_options = @settings.smtp_options
        Mail.defaults do
          delivery_method :smtp, smtp_options
        end
      else
        Mail.defaults do
          delivery_method :logger, severity: :debug
        end
      end
    end

  end
end
