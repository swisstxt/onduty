require 'twilio-ruby'

class TwilioApi

  def initialize(account_sid, auth_token, from_number)
    @account_sid = account_sid
    @auth_token  = auth_token
    @from_number = from_number
  end

  def call(number, twiml_url)
    client.account.calls.create(
      from: @from_number,
      to:   number,
      url:  twiml_url,
      method: 'GET'
    )
  end

  def sms(number, message)
    client.account.messages.create(
      from: @from_number,
      to:   number,
      body: message
    )
  rescue Twilio::REST::RequestError => e
    puts e.message
  end

  private

  def client
    @client ||= Twilio::REST::Client.new @account_sid, @auth_token
  end
end
