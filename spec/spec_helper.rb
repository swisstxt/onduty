
ENV["APP_ENV"] = "test"

require "minitest/autorun"
require "minitest/pride"
require "rack/test"

require_relative "../lib/onduty/server"

# seed test data
require_relative "data/seed_db"

def app
  Sinatra::Application
end

def default_login
  basic_authorize "admin", "password"
end
