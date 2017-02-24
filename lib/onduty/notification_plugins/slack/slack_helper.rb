module Onduty
  module SlackHelper
    def self.post_message(message, channel, api_token)
      Slack.configure {|config| config.token = api_token }
      Slack::Web::Client.new.chat_postMessage(
        channel: channel,
        text: message,
        as_user: true
      )
    end
  end
end
