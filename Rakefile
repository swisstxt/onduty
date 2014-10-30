require "sinatra/activerecord/rake"

# resolve path, ignoring symlinks
require "pathname"
$:.unshift File.expand_path("../lib", Pathname.new(__FILE__).realpath)
$:.unshift File.expand_path("../app", Pathname.new(__FILE__).realpath)

namespace :db do
  task :load_config do
    require "onduty/server_base"
  end
end
