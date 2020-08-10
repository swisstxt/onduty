module Onduty
  class Service
    require "uri"
    include Mongoid::Document
    embedded_in :alert

    field :host, type: String
    field :name, type: String

    # TODO: it would be more elegant to have these Icinga2-specific methods
    # in a helper rather then being in the model class

    def icinga2_host_link(icinga2_web_path)
      "#{icinga2_web_path}/monitoring/host/show?host=#{URI.escape(self.host)}"
    end

    def icinga2_service_link(icinga2_web_path)
      "#{icinga2_web_path}/monitoring/service/show?host=#{URI.escape(self.host)}&service=#{URI.escape(self.name)}"
    end

    def icinga2_acknowledge_url(icinga2_web_path)
      "#{icinga2_web_path}/actions/acknowledge-problem?service=#{URI.escape(self.icinga2_full_name)}"
    end

    private

    def icinga2_full_name
      "#{host}!#{name}"
    end

  end
end
