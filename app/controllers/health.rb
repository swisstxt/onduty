
get '/_health.json' do
  content_type :json
  @status = {}
  messages = []

  # Check for healthy MongoDb connection
  mongodb = Mongoid.client(:default).command(connectionStatus: 1)
  if (mongodb && mongodb.ok?)
    status = 200
    messages << "MongoDB service reachable"
    @status[:mongodb] = "OK"
  else
    status = 503
    messages << "MongoDB service unavailable"
    @status[:mongodb] = "ERROR"
  end

  # Check for enabled notification plugins
  if settings.notification_plugins.size < 1
    status = 503
    messages << "No notification plugin enabled"
    @status[:notification] = "ERROR"
  end

  # Add Twilio status information
  twilio = JSON.parse(Net::HTTP.get(
    URI("https://gpkpyklzq55q.statuspage.io/api/v2/status.json")
  ))
  @status[:twilio] = (twilio && twilio["status"]) ? twilio["status"] : "N/A"

  @status[:message] = messages.join("\n")
  { status: @status }.to_json
end
