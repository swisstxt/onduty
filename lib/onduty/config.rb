require 'yaml'
require 'erb'

module Onduty
  class Config

    def settings
      @settings ||= load_settings
    end

    def mongoid_config
      if settings.respond_to?(:mongoid_config)
        settings.mongoid_config
      else
        "config/mongoid.yml"
      end
    end

    def self.base_path
      base_path = File.expand_path("../../../", __FILE__)
    end

    private

    def load_settings
      s = {}
      # Base URL for menu links
      s['base_url'] = ENV.fetch('ONDUTY_BASE_URL', 'http://localhost:9292')

      # Secure onduty with simple auth
      s['admin_user'] = ENV.fetch('ONDUTY_ADMIN_USER', 'admin')
      s['admin_password'] = ENV.fetch('ONDUTY_ADMIN_PASSWORD', 'password')

      # When to trigger notifications for alerts
      s['alert_limit'] = ENV.fetch('ONDUTY_ALERT_LIMIT', 1).to_i

      # When to consider an existing alert as new (in hours)
      # when the time is below this value the count of an alert goes up
      s['alert_threshold'] = ENV.fetch('ONDUTY_ALERT_THRESHOLD', 2.0).to_f

      # Rack session secret
      s['session_secret'] = ENV.fetch('ONDUTY_SESSION_SECRET', SecureRandom.hex(64))

      # Icinga2 specific configurations
      s['icinga2_api_path'] = ENV.fetch('ONDUTY_ICINGA2_API_PATH', nil)
      s['icinga2_web_path'] = ENV.fetch('ONDUTY_ICINGA2_WEB_PATH', nil)
      s['icinga2_user'] = ENV.fetch('ONDUTY_ICINGA2_USER', nil)
      s['icinga2_password'] = ENV.fetch('ONDUTY_ICINGA2_PASSWORD', nil)

      #  notification plugins
      # Enable or disable notification plugins
      s['notification_plugins'] = ENV['ONDUTY_NOTIFICATION_PLUGINS'] ?
        ENV['ONDUTY_NOTIFICATION_PLUGINS'].split(",") : []
      # Email notification
      s['email_sender'] = ENV.fetch('ONDUTY_EMAIL_SENDER', 'alert@onduty')
      if ENV['ONDUTY_SMTP_ADDRESS']
        s['smtp_options'] = { address: ENV['ONDUTY_SMTP_ADDRESS'] }
      end
      # Twilio notifications (voice, SMS)
      # To find these visit https://www.twilio.com/user/account
      s['twilio_account_sid'] = ENV['ONDUTY_TWILIO_ACCOUNT_SID']
      s['twilio_auth_token'] = ENV['ONDUTY_TWILIO_ACCOUNT_TOKEN']
      s['twilio_from_number'] = ENV['ONDUTY_TWILIO_FROM_NUMBER']
      # Zendesk notifications
      s['zendesk_url'] = ENV['ONDUTY_ZENDESK_URL']
      s['zendesk_username'] = ENV['ONDUTY_ZENDESK_USERNAME']
      s['zendesk_token'] = ENV['ONDUTY_ZENDESK_TOKEN']
      # Slack notifications
      s['slack_api_token'] = ENV['ONDUTY_SLACK_API_TOKEN']
      s['slack_channel'] = ENV['ONDUTY_SLACK_CHANNEL']
      s
    end

  end
end
