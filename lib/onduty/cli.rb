require "mongoid"
require "thor"
require "ostruct"
require "erubis"

require "onduty/version"
require "onduty/config"
require "onduty/notification"
require "onduty/icinga"

Dir["./app/models/*.rb"].each { |file| require file }

module Onduty
  class Cli < Thor
    package_name "onduty-cli"
    include Thor::Actions

    # catch control-c and exit
    trap("SIGINT") {
      puts " bye"
      exit!
    }

    class_option :env,
      aliases: '-e',
      desc: 'environment to use',
      default: ENV['ONDUTY_ENV'] || 'production'

    # exit with return code 1 in case of a error
    def self.exit_on_failure?
      true
    end

    desc "version", "print onduty version number"
    def version
      say "onduty-cli v#{VERSION}"
    end
    map %w(-v --version) => :version

    desc "contacts", "list contacts"
    def contacts
      connect_to_db
      table = [%w(Name Phone Email Duty)]
      Contact.all.asc(:last_name).each do |contact|
        table << [
          contact.name,
          contact.phone,
          contact.email,
          contact.duty ? Onduty::Duty.types[contact.duty]: '-'
        ]
      end
      print_table table
    end

    desc "alerts", "list alerts"
    option :days_ago,
      desc: "limit timerange by days",
      aliases: '-t',
      default: 2,
      type: :numeric
    option :status,
      desc: "status of the alert",
      aliases: '-s',
      default: 'all',
      enum: %w(all ack nak)
    def alerts
      connect_to_db
      table = [%w(ID Name Created Trigger-Count Acknowledged)]
      alerts = Alert.created_after(days_ago(options[:days_ago]))
      case options[:status]
      when 'ack'
        alerts = alerts.acknowledged
      when 'nak'
        alerts = alerts.unacknowledged
      end
      alerts.order(created_at: :desc).each do |alert|
        table << [
          alert.id,
          alert.name,
          alert.count,
          alert.created_at,
          alert.acknowledged_at
        ]
      end
      print_table table
    end

    desc "create_alert", "create a new alert"
    option :name,
      desc: "name",
      aliases: '-n',
      required: true
    option :services,
      desc: "services (<host_1>!<service_1> <host_2>!<service2> ...)",
      aliases: '-s',
      type: Array,
      required: true
    option :alert,
      desc: "alert?",
      aliases: '-A',
      type: :boolean
    option :suspend_for,
      desc: "minutes of time to suspend alerts for given host/service",
      type: :numeric,
      default: 60
    def create_alert
      connect_to_db
      alert = Alert.where(
        name:    options[:name],
        acknowledged_at: nil
      ) do |alrt|
        options[:services].each do |s_str|
          alrt.services << Service.new(
            host: s_str.split('!').first,
            service: s_str.split('!').last
          )
        end
      end

      if alert.save
        if options[:alert] && alert.last_alert_at == nil
          if alert.count == onduty_config.alert_count
            say "Alerting...", :yellow
            invoke("trigger_alert", [alert.id], {})
          end
        end
        invoke "show_alert", [alert.id], {}
      else
        say "Error creating alert.", :red
      end
    end

    desc "trigger_alert [ID]", "trigger a given alert"
    option :escalation_delay,
      desc: "escalation delay in minutes for an alert which is unacknowledged for a certain amount of time",
      type: :numeric,
      default: 120
    def trigger_alert(id)
      connect_to_db
      alert = Alert.find(id)
      notification_opts = { html: true }
      unless alert.acknowledged_at
        if (Time.now - alert.created_at) > (options[:escalation_delay] * 60)
          say "Escalating alert.", :red
          notification_opts[:duty_type] = 2
        end
        Notification.new(alert.id, notification_opts).notify
      else
        say "Alert already acknowledged.", :yellow
      end
    end

    desc "show_alert [ID]", "show a given alert"
    def show_alert(id)
      connect_to_db
      alert = Alert.find(id)
      table = %w(id uid host service
      created_at acknowledged_at last_alert_at).map do |attr|
        [attr, alert[attr.to_sym] ? alert[attr.to_sym].to_s : '-']
      end
      print_table table
    rescue
      say "ERROR: Alert not found.", :red
    end

    desc "plugins", "show active plugins and their state"
    def plugins
      connect_to_db
      table = [%w(name status)]
      settings = Onduty::Config.new.settings
      Notification::PLUGINS.each do |plugin_name|
        plugin = Onduty.const_get(plugin_name).new(1)
        row = [plugin.name]
        if settings['notification_plugins'].include? plugin_name
          row << if plugin.valid_configuration?
            set_color("OK", :green)
          else
            set_color("Missing Options", :red)
          end
        else
          row << "disabled"
        end
        table << row
      end
      print_table table
    rescue
      say "ERROR: A valid alert and onduty contact is required.", :red
    end

    desc "acknowledege_service", "acknowledege_service"
    option :id,
      desc: "id",
      required: true
    option :comment,
      desc: "comment",
      aliases: '-c',
    def acknowledege_service
      opts = options[:comment] ? { comment: options[:comment] } : {}
      begin
        Alert.find(options[:id])
        if Onduty::Icinga.new.acknowledge_service(service, opts)
          say "Acknowledeged", :green
        else
          say "Error during acknowledegment.", :yellow
        end
      rescue => e
        say "ERROR: Alert not found.", :red
        exit 1
      end
    end

    no_commands do
      def connect_to_db(env = options[:env])
        Mongoid.load!(onduty_config.mongoid_config, env)
      rescue => e
        say "ERROR: Can't connect to the database: #{e.message}", :red
        exit 1
      end

      def onduty_config
        @onduty_config ||= Onduty::Config.new
      end

      def days_ago(x)
        Time.now - x.to_i * 3600 * 24
      end
    end

  end
end
