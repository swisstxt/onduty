module Onduty
  class MailNotification < Notification
    require 'pony'
    require "uri"

    def name
      "Onduty Mail Notification"
    end

    def valid_configuration?
      @contact.email && @settings.smtp_options
    end

    def trigger
      if @contact.email && @contact.alert_by_email == 1
        print "alert_#{@alert_id}: Sending alert email to #{@contact.name}..."
        @acknowledge_url = URI::join(
          @settings.base_url,
          "/alerts/#{@alert.id}/acknowledge#{ '.twiml' unless @options[:html] }?uid=#{@alert.uid}"
        ).to_s
        body = Erubis::Eruby.new(
          File.read(File.join(File.dirname(__FILE__), 'mail_notification.erb'))
        ).result(alert: @alert, contact: @contact, acknowledge_url: @acknowledge_url)
        Pony.mail({
          from:    "onduty@#{ @settings.email_sender ? @settings.email_sender : 'onduty'}",
          to:      @contact.email,
          subject: "[Alert #{@alert_id}] Alert from onduty" ,
          body:    body,
          via:     :smtp,
          via_options: @settings.smtp_options
        })
        puts "\t[OK]"
      end
    end
  end
end
