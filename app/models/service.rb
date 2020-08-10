module Onduty
  class Service
    require "uri"
    include Mongoid::Document
    embedded_in :alert

    field :host, type: String
    field :name, type: String
  end
end
