require 'bundler'
Bundler.require

require "sinatra/activerecord/rake"

# resolve path, ignoring symlinks
require "pathname"
%w(../lib ../app).each do |path|
  $:.unshift File.expand_path(
    path, Pathname.new(__FILE__).realpath
  )
end

namespace :db do
  task :load_config do
    require "onduty/server"
  end
end
