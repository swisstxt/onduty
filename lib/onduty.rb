# libs from gems
require 'sqlite3'
require 'sinatra'
require 'sinatra/contrib'
require "sinatra/activerecord"
require "sinatra/config_file"
require 'twilio-ruby'

# our own dependecies
require_relative "onduty/version"
require_relative "onduty/twilio_api"
require_relative "onduty/models/alert"
require_relative "onduty/models/contact"
