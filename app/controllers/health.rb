
get '/_health.json' do
  content_type :json
  @status = {}
  mongodb = Mongoid.client(:default).command(connectionStatus: 1)
  @status[:mongodb] = (mongodb && mongodb.ok?) ? "OK" : "ERROR"
  twilio = JSON.parse(Net::HTTP.get(
    URI("https://gpkpyklzq55q.statuspage.io/api/v2/status.json")
  ))
  @status[:twilio] = (twilio && twilio["status"]) ? twilio["status"] : "N/A"
  { status: @status }.to_json
end
