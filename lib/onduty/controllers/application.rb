set :environment, :development #(ENV["RACK_ENV"] || :development).to_sym
set :root, File.join(File.dirname(__FILE__), '..')
set :bind, '0.0.0.0'

c_file = nil
[
  '/etc/onduty.yml',
  '/etc/onduty/onduty.yml',
  './config/onduty.yml',
  './config/onduty.example.yml'
].each do |config|
  if File.exists?(config)
    c_file = config
    break
  end
end
if c_file
  config_file c_file
else
  raise "Error: No configuration file found."
end

require_relative "../helpers/application"

get '/' do
  redirect '/contacts'
end

not_found do
  @text = "That page doesn't exist"
  @title = "404"
  erb :'404'
end
