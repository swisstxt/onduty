module Onduty
  class Notification

    require 'logger'
    require 'uri'

    Dir[File.expand_path('../notification_plugins/**/*.rb', __FILE__)].each { |f| require f }

    attr_reader :alert_id, :options, :logger

    def initialize(alert_id, options = {})
      @alert_id = alert_id
      @alert = Onduty::Alert.find(alert_id)
      @contact = Onduty::Contact.where(duty: options[:duty_type] || 1).first
      @settings = OpenStruct.new(
        YAML::load(File.open(Onduty::Config.file))
      )
      @options = options
      @logger = initialize_logger
    end

    def acknowledge_url
      URI::join(
        @settings.base_url,
        "/alerts/#{@alert.id}/acknowledge#{ '.twiml' unless @options[:html] }?uid=#{@alert.uid}"
      ).to_s
    end

    def name
      "Onduty Generic Notification"
    end

    def initialize_logger
      @logger = Logger.new(STDOUT).tap do |log|
        STDOUT.sync = true
        log.progname = self.name
        log.level = Logger::INFO
      end
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
         notification_plugin.logger.error "Plugin can't be used because of missing configuration options."
       end
      end
      @alert.last_alert_at = Time.now
      @alert.save!
    rescue => e
      logger.error "Error triggering alert with ID #{@alert_id}: #{e.message}"
      false
    end
  end
end
