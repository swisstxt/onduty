require "sqlite3"
require "active_record"
require "thor"

require "onduty/version"
require "onduty/config"
require "onduty/twilio_api"

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
      say "onduty-cli v#{Onduty::VERSION}"
    end
    map %w(-v --version) => :version

    desc "contacts", "list contacts"
    def contacts
      connect_to_db
      table = [%w(Name Phone Email Duty)]
      ::Contact.all.order(:last_name).each do |contact|
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
      ::Duty.all.each do |duty|
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
      table = [%w(ID UID Message Created Acknowledged)]
      alerts =::Alert.created_after(days_ago(options[:days_ago]))
      case options[:status]
      when 'ack'
        alerts = alerts.acknowledged
      when 'nak'
        alerts = alerts.unacknowledged
      end
      alerts.order(created_at: :desc).each do |alert|
        table << [
          alert.id,
          alert.uid,
          alert.message,
          alert.created_at,
          alert.acknowledged_at
        ]
      end
      print_table table
    end


    desc "create_alert MESSAGE", "create a new alert"
    def create_alert(message)
      connect_to_db
      if ::Alert.create(message: message)
        say "Ok."
      else
        say "Error creating alert."
      end
    end

    no_commands do
      def connect_to_db(env = options[:env])
        db_settings = YAML::load(
          File.open('config/database.yml')
        )
        ActiveRecord::Base.establish_connection(
          db_settings[env]
        )
      end

      def days_ago(x)
        Time.now - x.to_i * 3600 * 24
      end
    end

  end
end
