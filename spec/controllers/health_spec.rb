require_relative "../spec_helper"

include Rack::Test::Methods

describe "health_controller" do

  it "should successfully return the health page as json" do
    header 'Accept', 'application/json'
    get '/_health.json'
    last_response.status.must_equal 200
    health = JSON.parse(last_response.body)
    assert_includes health.keys, "status"
    assert_includes health["status"].keys, "mongodb"
    assert_includes health["status"].keys, "notification"
    assert_includes health["status"].keys, "message"
  end

end
