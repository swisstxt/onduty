module Onduty
  class Service
    include Mongoid::Document
    embedded_in :alert

    field :host, type: String
    field :service, type: String

    def name
      "#{host}!#{service}"
    end

  end
end
