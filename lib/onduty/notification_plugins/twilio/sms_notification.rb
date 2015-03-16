module Onduty
  class SmsNotification < Notification
    def name
      "Onduty SMS Notification"
    end

    def valid_configuration?
      @contact.phone && api.valid_credentials?
    end

    def trigger
      if @contact.phone && @contact.alert_by_sms == 1
        api.sms(@contact.phone, alert.message)
        logger.info "Sent alert SMS with ID #{@alert_id} to #{@contact.name}."
      end
    rescue => e
      logger.error "Error sending SMS: #{e.message}"
    end

    private

    def api
      @api ||= TwilioApi.new(
        account_sid: @settings.account_sid,
        auth_token: @settings.auth_token,
        from_number: @settings.from_number
      )
    end

  end
end
