require_relative "../spec_helper"

include Rack::Test::Methods

describe "application_controller" do

  it "should successfully return the 404-page for missing pages" do
    get '/nothing-here'
    last_response.status.must_equal 404
    last_response.body.must_include '404 - Page not found'
  end

  it "should deny access for unauthenticated users" do
    get '/'
    last_response.status.must_equal 401
  end

  it "should allow access to stats with admin login" do
    default_login
    get '/'
    last_response.status.must_equal 200
  end

end
