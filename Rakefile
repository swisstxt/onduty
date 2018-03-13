require 'bundler'
Bundler.require

require "minitest"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.warning = false
end

desc "Run Tests"
task :default => :test

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

desc "Generate secret"
task :secret do
  require 'securerandom'
  puts SecureRandom.hex(64)
end
