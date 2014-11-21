require 'yaml'

module Onduty
  class Config

    def initialize(config_file = Onduty::Config.file)
      @config_file = config_file
    end

    def settings
      @settings ||= YAML::load(
        File.open(@config_file)
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
      config_file = [
        '/etc/onduty.yml',
        '/etc/onduty/onduty.yml',
        File.join(Config.base_path, 'config/onduty.yml'),
        File.join(Config.base_path, 'config/onduty.example.yml')
      ].find {
        |config| File.exists? config
      }
    end

  end
end
