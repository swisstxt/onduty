require 'sqlite3'
require 'sinatra'
require 'sinatra/contrib'
require "sinatra/activerecord"
require "sinatra/config_file"
require 'twilio-ruby'

require_relative "onduty/version"
require_relative "onduty/twilio_api"

require "./app/controllers/application"
