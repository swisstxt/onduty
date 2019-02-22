module Onduty
  module SlackHelper
    def self.post_message(channel, api_token, message, attachments)
      Slack.configure { |config| config.token = api_token }
      Slack::Web::Client.new.chat_postMessage(
        channel: channel,
        text: message,
        attachments: attachments,
        as_user: true
      )
    end
  end
end
