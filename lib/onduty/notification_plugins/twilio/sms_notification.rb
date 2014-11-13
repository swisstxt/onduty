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
        twilio.sms(@contact.phone, @alert.message)
        logger.info "Sent alert SMS with ID #{@alert_id} to #{@contact.name}."
      end
    rescue => e
      logger.error "Error sending SMS: #{e.message}"
    end
  end
end
