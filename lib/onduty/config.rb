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

    def self.file
      base_path = File.expand_path("../../../", __FILE__)
      config_file = [ '/etc/onduty.yml',
        '/etc/onduty/onduty.yml',
        File.join(base_path, 'config/onduty.yml'),
        File.join(base_path, 'config/onduty.example.yml')
      ].find {
        |config| File.exists? config
      }
    end

  end
end
