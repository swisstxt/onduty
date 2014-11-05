module Onduty
  class SmsNotification < Notification
    def name
      "Onduty SMS Notification"
    end

    def valid_configuration?
      @contact.phone && @settings.account_sid &&
        @settings.auth_token && @settings.from_number
    end

    def trigger
      if @contact.phone && @contact.alert_by_sms == 1
        twilio = TwilioApi.new(@settings.account_sid, @settings.auth_token, @settings.from_number)
        print "alert_#{@alert_id}: Sending alert SMS to #{@contact.name}..."
        twilio.sms(@contact.phone, @alert.message)
        puts "\t\t[OK]"
      end
    end
  end
end
