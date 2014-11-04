module Onduty
  class MailNotification < Notification
    require 'pony'
    require "uri"

    def name
      "Onduty Mail Notification"
    end

    def trigger
      if @contact.email && @contact.alert_by_email == 1
        print "alert_#{@alert_id}: Sending alert email to #{@contact.name}..."
        Pony.mail({
          from:    "onduty@#{ @settings.email_sender ? @settings.email_sender : 'onduty'}",
          to:      @contact.email,
          subject: "[Alert #{@alert_id}] Alert from onduty" ,
          body:    "Message: #{@alert.message}
                    \nHost: #{@alert.host}
                    \nService: #{@alert.service}
                    \nAcknowledge: " +
                    URI::join(
                      @settings.base_url,
                      "/alerts/#{@alert.id}/acknowledge#{ '.twiml' unless @options[:html] }?uid=#{@alert.uid}"
                    ).to_s,
          via:     :smtp,
          via_options: @settings.smtp_options
        })
        puts "\t[OK]"
      end
    end
  end
end
