require "onduty/twilio_api"
require "pony"
require "uri"

module Onduty
  class TwilioAlert

    def self.trigger(alert_id, options = {})
      alert = Onduty::Alert.find(alert_id)
      contact = Onduty::Duty.find(1).contact
      settings = OpenStruct.new(
        YAML::load(File.open(Onduty::Config.file))
      )
      twilio = TwilioApi.new(settings.account_sid, settings.auth_token, settings.from_number)

      print "alert_#{alert_id}: Initiating call to #{contact.name}..."
      #twilio.call(
      #  contact.phone,
      #  URI::join(settings.base_url, "/alerts/#{alert.id}.twiml?uid=#{alert.uid}")
      #)
      puts "\t\t[OK]"

      if contact.phone && contact.alert_by_sms == 1
        print "alert_#{alert_id}: Sending alert SMS to #{contact.name}..."
        #twilio.sms(contact.phone, alert.message)
        puts "\t\t[OK]"
      end

      if contact.email && contact.alert_by_email == 1
        print "alert_#{alert_id}: Sending alert email to #{contact.name}..."
        Pony.mail({
          from:    "onduty@#{ settings.email_sender ? settings.email_sender : 'onduty'}",
          to:      contact.email,
          subject: "Alert from onduty [Alert #{alert_id}]" ,
          body:    "Message: #{alert.message}
                    \nHost: #{alert.host}
                    \nService: #{alert.service}
                    \nAcknowledge: " +
                    URI::join(
                      settings.base_url,
                      "/alerts/#{alert.id}/acknowledge#{ '.twiml' unless options[:html] }?uid=#{alert.uid}"
                    ).to_s,
          via:     :smtp,
          via_options: { address: 'smtp3.swisstxt.ch' }
        })
        puts "\t[OK]"
      end

      # Update last alerted info
      alert.last_alert_at = Time.now
      alert.save
    rescue => e
      puts
      puts "Error triggering alert with ID #{alert_id}: #{e.message}"
    end
  end
end
