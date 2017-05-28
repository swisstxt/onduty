require 'onduty/server_base'

if file = Onduty::Config.file
  set Onduty::Config.new.settings
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
