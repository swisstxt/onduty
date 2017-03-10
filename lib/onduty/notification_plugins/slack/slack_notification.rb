module Onduty
  class SlackNotification < Notification
    require 'slack-ruby-client'
    require_relative './slack_helper'

    def name
      "Onduty Slack Notification"
    end

    def valid_configuration?
      @settings.slack_api_token && @settings.slack_channel
    end

    def trigger
      message = Erubis::Eruby.new(
        File.read(File.join(File.dirname(__FILE__), 'slack_notification.erb'))
      ).result(
        alert: @alert,
        contact: @contact,
        acknowledge_url: acknowledge_url(html_link: true)
      )
      Onduty::SlackHelper.post_message(
        message,
        @settings.slack_channel,
        @settings.slack_api_token
      )
      logger.info "Succesfully sent Slack message for alert with ID #{@alert.id}."
    rescue => e
      logger.error "Error creating Slack message: #{e.message}"
    end
  end
end
