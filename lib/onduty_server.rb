require 'sqlite3'
require 'sinatra'
require 'sinatra/contrib'
require "sinatra/activerecord"
require "sinatra/config_file"
require 'twilio-ruby'

require_relative "onduty/version"
require_relative "onduty/twilio_api"

set :environment, :development #(ENV["RACK_ENV"] || :development).to_sym
set :root, File.join(File.dirname(__FILE__), '..', 'app')
set :bind, '0.0.0.0'

c_file = nil
[
  '/etc/onduty.yml',
  '/etc/onduty/onduty.yml',
  '../config/onduty.yml',
  '../config/onduty.example.yml'
].each do |config|
  if File.exists?(File.join(File.dirname(__FILE__), config))
    c_file = config
    break
  end
end
if c_file
  config_file c_file
else
  puts "Error: No configuration file found."
  exit 1
end

# require models
Dir['./app/models/*.rb'].each {|file| require file }

# require helpers
Dir['./app/helpers/*.rb'].each {|file| require file }

# require conrollers
Dir['./app/controllers/*.rb'].each {|file| require file }
