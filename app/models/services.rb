module Onduty
  class Service
    include Mongoid::Document
    embedded_in :alert

    field :host, type: String
    field :name, type: String

    def full_name
      "#{host}!#{name}"
    end

  end
end
