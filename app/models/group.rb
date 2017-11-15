module Onduty
  class Group
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, type: String
    field :position, type: Integer, default: 0

    has_many :contacts
    has_many :alerts

    validates_presence_of :name
  end
end
