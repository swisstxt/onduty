module Onduty
  class Notification

    Dir[File.expand_path('../notification_plugins/**/*.rb', __FILE__)].each { |f| require f }

    def initialize(alert_id, options = {})
      @alert_id = alert_id
      @alert = Onduty::Alert.find(alert_id)
      @contact = Onduty::Duty.find(1).contact
      @settings = OpenStruct.new(
        YAML::load(File.open(Onduty::Config.file))
      )
      @options = options
    end

    def name
      "Onduty Generic Notification"
    end

    def plugins
      @settings.notification_plugins || %w(VoiceNotification SmsNotification MailNotification)
    end

    def notify
      plugins.each do |notification_plugin|
       Onduty.const_get(notification_plugin).new(@alert_id, @options).trigger
      end
      @alert.last_alert_at = Time.now
      @alert.save
    rescue => e
      puts
      puts "Error triggering alert with ID #{@alert_id}: #{e.message}"
    end
  end
end
