
require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    require_relative 'lib/onduty'
    ActiveSupport::Deprecation.silenced = true
  end
end
