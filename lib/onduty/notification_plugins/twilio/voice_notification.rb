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
      print "alert_#{@alert_id}: Initiating call to #{@contact.name}..."
      twilio.call(
        @contact.phone,
        URI::join(@settings.base_url, "/alerts/#{@alert.id}.twiml?uid=#{@alert.uid}")
      )
      puts "\t\t[OK]"
    end
  end
end
