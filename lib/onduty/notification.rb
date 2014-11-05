module Onduty
  class Notification

    Dir[File.expand_path('../notification_plugins/**/*.rb', __FILE__)].each { |f| require f }

    attr_reader :alert_id, :options

    def initialize(alert_id, options = {})
      @alert_id = alert_id
      @alert = Onduty::Alert.find(alert_id)
      @contact = Onduty::Duty.find(options[:duty_type] || 1).contact
      @settings = OpenStruct.new(
        YAML::load(File.open(Onduty::Config.file))
      )
      @options = options
    end

    def name
      "Onduty Generic Notification"
    end

    def valid_configuration?
      true
    end

    def plugins
      @settings.notification_plugins || %w(VoiceNotification SmsNotification MailNotification)
    end

    def notify
      plugins.each do |plugin|
       notification_plugin = Onduty.const_get(plugin).new(@alert_id, @options)
       if notification_plugin.valid_configuration?
         notification_plugin.trigger
       else
         puts "#{notification_plugin} can't be used because of missing configuration options."
       end
      end
      @alert.last_alert_at = Time.now
      @alert.save
    rescue => e
      puts
      puts "Error triggering alert with ID #{@alert_id}: #{e.message}"
      false
    end
  end
end
