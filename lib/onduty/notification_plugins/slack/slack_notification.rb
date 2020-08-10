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
      message = ":lightning: *"
      message += "#{@alert.group.name} " if @alert.group
      message += "Alert*"

      alert_text = @alert.shortened_name(@settings.alert_shortener_regex)

      attachments = [
        {
          "text": alert_text,
          "color": "danger",
          "attachment_type": "default",
          "actions": [
            {
              "text": "Acknowledge",
              "type": "button",
              "url": acknowledge_url(html_link: true),
              "style": "primary",
            },
            {
              "text": "Details",
              "type": "button",
              "url": detail_url,
              "style": "default",
            },
          ]
        }
      ]
      attachments[0][:actions].shift if @alert.acknowledged?

      Onduty::SlackHelper.post_message(
        @settings.slack_channel,
        @settings.slack_api_token,
        message,
        attachments
      )

      logger.info "Succesfully sent Slack message for alert with ID #{@alert.id}."
    rescue => e
      logger.error "Error creating Slack message: #{e.message}"
      if ENV['APP_ENV'] == 'development'
        logger.info "Backtrace: #{e.backtrace}"
      end
    end
  end
end
