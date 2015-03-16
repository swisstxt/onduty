module Onduty
  class VoiceNotification < Notification

    def name
      "Onduty Voice Notification"
    end

    def valid_configuration?
      @contact.phone && api.valid_credentials?
    end

    def trigger
      api.call(
        @contact.phone,
        URI::join(@settings.base_url, "/alerts/#{alert.id}.twiml?uid=#{alert.uid}")
      )
      logger.info "Initiated phone call for alert with ID #{@alert_id} to #{@contact.name}."
    rescue => e
      logger.error "Error initiated phone call: #{e.message}"
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
