module Onduty
  class Service
    require "uri"
    include Mongoid::Document
    embedded_in :alert

    field :host, type: String
    field :name, type: String

    def full_name
      "#{host}!#{name}"
    end

    def icinga2_host_link(icinga2_web_path)
      "#{icinga2_web_path}/monitoring/host/show?host=#{URI.escape(self.host)}"
    end

    def icinga2_service_link(icinga2_web_path)
      "#{icinga2_web_path}/monitoring/service/show?host=#{URI.escape(self.host)}&service=#{URI.escape(self.name)}"
    end

  end
end
