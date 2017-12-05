require 'twilio-ruby'

module Onduty
  class TwilioApi

    def initialize(options = {})
      @account_sid = options[:account_sid]
      @auth_token  = options[:auth_token]
      @from_number = options[:from_number]
    end

    def valid_credentials?
      @account_sid && @auth_token && @from_number
    end

    def call(number, twiml_url)
      client.api.account.calls.create(
        from: @from_number,
        to:   number,
        url:  twiml_url,
        method: 'POST'
      )
    end

    def sms(number, message)
      client.api.account.messages.create(
        from: @from_number,
        to:   number,
        body: message
      )
    rescue Twilio::REST::RestError => e
      puts e.message
    end

    private

    def client
      @client ||= Twilio::REST::Client.new @account_sid, @auth_token
    end
  end
end
