require_relative "../spec_helper"

include Rack::Test::Methods

describe "settings_controller" do

  it "should deny access for unauthenticated users to settings" do
    get '/settings'
    last_response.status.must_equal 401
  end

  it "should successfully return the settings page to users" do
    default_login
    get '/settings'
    last_response.status.must_equal 200
    last_response.body.must_include "<h1>Settings</h1>"
  end

end
