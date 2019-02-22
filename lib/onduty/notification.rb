module Onduty
  class Notification

    require 'logger'
    require 'uri'

    AVAILABLE_PLUGINS = Dir[File.expand_path('../notification_plugins/**/*.rb', __FILE__)].map do |f|
      require f
      class_name = File.basename(f, '.rb').split('_').map{|f| f.capitalize}.join
      class_name =~ /.*Notification/ ? class_name : nil
    end.compact

    DEFAULT_PLUGINS = %w(VoiceNotification MailNotification)

    SETTINGS = OpenStruct.new(Onduty::Config.new.settings)

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
      if options[:force] || alert.count >= (SETTINGS.alert_limit.to_i || 0)
        begin
          self.plugins.each do |plugin|
            notification_plugin = Onduty.const_get(plugin).new(alert, options)
            if notification_plugin.valid_configuration?
              notification_plugin.trigger
            else
              notification_plugin.logger.error(
                "Plugin #{plugin} can't be used because of missing configuration options."
              )
            end
          end
          alert.last_alert_at = Time.now
          alert.count += 1
          alert.save!
        rescue => e
          logger.error "Error triggering alert with ID #{alert.id}: #{e.message}"
          if ENV['APP_ENV'] == 'development'
            logger.info "Backtrace: #{e.backtrace}"
          end
          false
        end
      else
        alert.count += 1
        alert.save!
      end
    end

    def initialize(alert, options = {})
      @alert = alert
      @duty_type = options[:duty_type] || 1
      @options = options
      @settings = SETTINGS
      @logger = Onduty::Notification.logger
      self.set_group_and_contact
    end

    # find group and contact
    # if nobody from the alert-group is onduty try the next group (ordered by group position)
    def set_group_and_contact
      if @alert.group && @alert.group.contacts.where(duty: @duty_type).any?
        @group = @alert.group
        @contact = @alert.group.contacts.where(duty: @duty_type).first
      else
        Onduty::Group.asc(:position).all.detect do |group|
           if group.contacts.where(duty: @duty_type).any?
             @group = group
             @contact = group.contacts.where(duty: @duty_type).first
           end
         end
      end
    end

    def acknowledge_url(opts = {})
      ext = opts[:html_link] ? 'html' : 'twiml'
      URI::join(
        SETTINGS.base_url,
        "/alerts/#{@alert.id}/acknowledge.#{ext}?uid=#{@alert.uid}"
      ).to_s
    end

    def detail_url
      URI::join(SETTINGS.base_url, "/alerts/#{@alert.id}").to_s
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
