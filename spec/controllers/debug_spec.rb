require_relative "../spec_helper"

include Rack::Test::Methods

describe "debug_controller" do

  it "should deny access for unauthenticated users to debug" do
    get '/debug'
    last_response.status.must_equal 401
  end

  it "should successfully return the debug page for admin users" do
    default_login
    get '/debug'
    last_response.status.must_equal 200
    last_response.body.must_include "<h1>Settings (Debug)</h1>"
  end

end
