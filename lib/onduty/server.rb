require 'onduty/server_base'

set :environment,   (ENV["RACK_ENV"] || :development).to_sym
set :root,          File.join(File.dirname(__FILE__), '../../', 'app')
set :public_folder, File.join(File.dirname(__FILE__), '../../', 'public')

if c_file = Onduty::Config.file
  config_file c_file
else
  puts "Error: No configuration file found."
  exit 1
end

module Onduty
  class Server < Sinatra::Base
    # require models, helpers and controllers
    %w(models helpers controllers).each do |type|
      files = Dir["./app/#{type}/*.rb"]
      files.each do |file|
        require file
      end
    end
  end
end
