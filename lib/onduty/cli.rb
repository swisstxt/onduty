require "sqlite3"
require "active_record"
require "thor"
require "ostruct"
require "erubis"

require "onduty/version"
require "onduty/config"
require "onduty/notification"

#set :environment, :development #(ENV["RACK_ENV"] || :development).to_sym

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
      default: 'development'

    # exit with return code 1 in case of a error
    def self.exit_on_failure?
      true
    end

    desc "version", "print cloudstack-cli version number"
    def version
      say "onduty-cli v#{VERSION}"
    end
    map %w(-v --version) => :version

    desc "contacts", "list contacts"
    def contacts
      connect_to_db
      table = [%w(Name Phone Email Duty)]
      Contact.all.order(:last_name).each do |contact|
        table << [
          contact.name,
          contact.phone,
          contact.email,
          contact.duty ? contact.duty.name : '-'
        ]
      end
      print_table table
    end

    desc "duties", "list duties"
    def duties
      connect_to_db
      table = [%w(Name Contact)]
      Duty.all.each do |duty|
        table << [
          duty.name,
          duty.contact ? duty.contact.name : "-"
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
      table = [%w(ID Host Service Created Acknowledged)]
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
          alert.host,
          alert.service,
          alert.created_at,
          alert.acknowledged_at
        ]
      end
      print_table table
    end

    desc "create_alert MESSAGE", "create a new alert"
    option :message,
      desc: "alert message",
      aliases: '-m',
      required: true
    option :host,
      desc: "host",
      aliases: '-H',
      required: true
    option :service,
      desc: "service",
      aliases: '-s',
      required: true
    option :alert,
      desc: "alert?",
      aliases: '-A',
      type: :boolean
    def create_alert
      connect_to_db
      alert = Alert.new(
        message: options[:message],
        host:    options[:host],
        service: options[:service]
      )
      if alert.save
        say "Created alert:"
        invoke "show_alert", [alert.id], {}
      else
        say "Error creating alert."
      end
    end

    desc "trigger_alert [ID]", "trigger a given alert"
    option :escalate,
      desc: "escalate",
      type: :boolean
    def trigger_alert(id)
      connect_to_db
      options = { html: true }
      options[:duty_type] = 2 if options[:escalate]
      Notification.new(id, options).notify
    end

    desc "show_alert [ID]", "show a given alert"
    def show_alert(id)
      connect_to_db
      alert = Alert.find(id)
      table = %w(id uid host service message
      created_at acknowledged_at last_alerted_at).map do |attr|
        [attr, alert[attr.to_sym] ? alert[attr.to_sym].to_s : '-']
      end
      print_table table
    rescue
      say "Alert not found.", :red
    end

    desc "plugins", "show active plugins and their state"
    def plugins
      connect_to_db
      table = [%w(name status)]
      notification = Notification.new(Alert.first)
      notification.plugins.each do |plugin_name|
        plugin = Onduty.const_get(plugin_name).new(notification.alert_id, notification.options)
        table << [plugin.name, plugin.valid_configuration? ? "OK" : "Missing Options"]
      end
      print_table table
    rescue
      say "A valid alert and onduty contact is required.", :red
    end

    no_commands do
      def connect_to_db(env = options[:env])
        db_settings = YAML::load(
          File.open('config/database.yml')
        )
        ActiveRecord::Base.establish_connection(
          db_settings[env]
        )
      rescue
        say "Error: Can't connect to the database.", :red
        exit 1
      end

      def days_ago(x)
        Time.now - x.to_i * 3600 * 24
      end
    end

  end
end
