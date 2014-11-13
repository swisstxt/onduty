module Onduty
  class VoiceNotification < Notification

    def name
      "Onduty Voice Notification"
    end

    def valid_configuration?
      @contact.phone && @settings.account_sid &&
        @settings.auth_token && @settings.from_number
    end

    def trigger
      twilio = TwilioApi.new(@settings.account_sid, @settings.auth_token, @settings.from_number)
      logger.info "Initiating call for alert with ID #{@alert_id} to #{@contact.name}."
      twilio.call(
        @contact.phone,
        URI::join(@settings.base_url, "/alerts/#{@alert.id}.twiml?uid=#{@alert.uid}")
      )
    end
  end
end
