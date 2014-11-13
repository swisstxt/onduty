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
      twilio.call(
        @contact.phone,
        URI::join(@settings.base_url, "/alerts/#{@alert.id}.twiml?uid=#{@alert.uid}")
      )
      logger.info "Initiated phone call for alert with ID #{@alert_id} to #{@contact.name}."
    rescue => e
      logger.error "Error initiated phone call: #{e.message}"
    end
  end
end
