module Onduty
  class VoiceNotification < Notification

    def name
      "Onduty Twilio Voice Notification"
    end

    def valid_configuration?
      api.valid_credentials?
    end

    def trigger
      if @contact.phone
        api.call(
          @contact.phone,
          URI::join(@settings.base_url, "/alerts/#{alert.id}.twiml?uid=#{@alert.uid}")
        )
        logger.info "Initiated phone call for alert with ID #{@alert.id} to #{@contact.name} (#{@contact.group ? @contact.group.name : '-'})."
      else
        logger.warn "#{@contact.name} has no phone number configured! Can't initiate phone call."
      end
    rescue => e
      logger.error "Error initiated phone call: #{e.message}"
      unless ENV['APP_ENV'] == "production"
        logger.info "Backtrace: #{e.backtrace}"
      end
    end

    private

    def api
      @api ||= TwilioApi.new(
        account_sid: @settings.twilio_account_sid,
        auth_token: @settings.twilio_auth_token,
        from_number: @settings.twilio_from_number
      )
    end

  end
end
