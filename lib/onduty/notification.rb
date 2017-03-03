module Onduty
  class Notification

    require 'logger'
    require 'uri'

    AVAILABLE_PLUGINS = Dir[File.expand_path('../notification_plugins/**/*.rb', __FILE__)].map do |f|
      require f
      class_name = File.basename(f, '.rb').split('_').map{|f| f.capitalize}.join
      class_name =~ /.*Notification/ ? class_name : nil
    end.compact

    DEFAULT_PLUGINS = %w(VoiceNotification SmsNotification MailNotification)

    SETTINGS = OpenStruct.new(
      YAML::load(File.open(Onduty::Config.file))
    )

    attr_reader :alert, :options, :logger

    def self.logger
      Logger.new(STDOUT).tap do |log|
        STDOUT.sync = true
        log.progname = self.name
        log.level = Logger::INFO
      end
    end

    def self.plugins
      SETTINGS.notification_plugins || DEFAULT_PLUGINS
    end

    def self.notify_all(alert, options = {})
      if options[:force] || alert.count >= (SETTINGS.alert_count || 0)
        begin
          self.plugins.each do |plugin|
           notification_plugin = Onduty.const_get(plugin).new(alert, options)
           if notification_plugin.valid_configuration?
             notification_plugin.trigger
           else
             notification_plugin.logger.error "Plugin #{plugin} can't be used because of missing configuration options."
           end
          end
          alert.last_alert_at = Time.now
          alert.count += 1
          alert.save!
        rescue => e
          logger.error "Error triggering alert with ID #{alert.id}: #{e.message}"
          false
        end
      else
        alert.count += 1
        alert.save!
      end
    end

    def initialize(alert, options = {})
      @alert = alert
      @contact = Onduty::Contact.where(duty: options[:duty_type] || 1).first ||
        Contact.new(first_name: "Jon", last_name: "Doe", phone: "+412223344")
      @options = options
      @settings = SETTINGS
      @logger = Onduty::Notification.logger
    end

    def acknowledge_url(opts = {})
      ext = opts[:html_link] ? 'html' : 'twiml'
      URI::join(
        SETTINGS.base_url,
        "/alerts/#{@alert.id}/acknowledge.#{ext}?uid=#{@alert.uid}"
      ).to_s
    end

    def name
      "Onduty Generic Notification"
    end

    def enabled?
      Onduty::Notification.plugins.include? self.name
    end

    def valid_configuration?
      true
    end
  end
end
