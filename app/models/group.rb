module Onduty
  class Group
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, type: String
    field :order, type: Integer, default: 0

    has_many :contacts

    validates_presence_of :name
  end
end
