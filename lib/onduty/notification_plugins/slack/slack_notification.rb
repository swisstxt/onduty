module Onduty
  class SlackNotification < Notification
    require 'slack-ruby-client'

    def name
      "Onduty Slack Notification"
    end

    def valid_configuration?
      @settings.slack_api_token && @settings.slack_channel
    end

    def trigger
      Slack.configure do |config|
        config.token = @settings.slack_api_token
      end
      client = Slack::Web::Client.new
      message = Erubis::Eruby.new(
        File.read(File.join(File.dirname(__FILE__), 'slack_notification.erb'))
      ).result(
        alert: alert,
        alert_type: @options[:alert_type] || "alert",
        contact: @contact,
        acknowledge_url: acknowledge_url(html_link: true)
      )
      client.chat_postMessage(
        channel: @settings.slack_channel,
        text: message,
        as_user: true
      )
      logger.info "Created Slack message for alert with ID #{@alert_id}."
    rescue => e
      logger.error "Error creating Slack message: #{e.message}"
    end
  end
end
