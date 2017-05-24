require 'yaml'
require 'erb'

module Onduty
  class Config

    def initialize(config_file = Onduty::Config.file)
      @config_file = config_file
    end

    def settings
      @settings ||= YAML::load(
        ERB.new(File.read @config_file).result
      )
    end

    def mongoid_config
      if settings.respond_to?(:mongoid_config)
        settings.mongoid_config
      else
        "config/mongoid.yml"
      end
    end

    def self.base_path
      base_path = File.expand_path("../../../", __FILE__)
    end

    def self.file
      default_config = File.join(Config.base_path, 'config/default_onduty.yml')
      File.exists?(default_config) ? default_config : nil
    end

  end
end
