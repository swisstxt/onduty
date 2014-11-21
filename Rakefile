require 'bundler'
Bundler.require

# resolve path, ignoring symlinks
require "pathname"
%w(../lib ../app).each do |path|
  $:.unshift File.expand_path(
    path, Pathname.new(__FILE__).realpath
  )
end

desc "Push a tag with the current version to git"
task :tag do
  require 'onduty/version'
  puts "Creating a tag for v#{Onduty::VERSION}..."
  %x[git tag v#{Onduty::VERSION}]
  %x[git push --tags]
  puts "Finished!"
end
