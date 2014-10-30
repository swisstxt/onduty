require 'onduty/server_base'

set :environment, :development #(ENV["RACK_ENV"] || :development).to_sym
set :root, File.join(File.dirname(__FILE__), '../../', 'app')
set :bind, '0.0.0.0'

if c_file = Onduty::Config.file
  config_file c_file
else
  puts "Error: No configuration file found."
  exit 1
end

# require models, helpers and controllers
%w(models helpers controllers).each do |type|
  files = Dir["./app/#{type}/*.rb"]
  files.each do |file|
    require file
  end
end
