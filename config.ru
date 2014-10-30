#!/usr/bin/env ruby
# encoding: UTF-8

# resolve path, ignoring symlinks
require "pathname"
$:.unshift File.expand_path("../lib", Pathname.new(__FILE__).realpath)
$:.unshift File.expand_path("../app", Pathname.new(__FILE__).realpath)

require "onduty/server"

run Sinatra::Application
