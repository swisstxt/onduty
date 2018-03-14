module Onduty
  class Group
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, type: String
    field :position, type: Integer, default: 0

    has_many :contacts
    has_many :alerts

    validates_presence_of :name
    validates_uniqueness_of :name

    def self.find_or_default(name)
      group = Onduty::Group.where(name: name).first
      group ||= Onduty::Group.first_or_default
    end

    def self.first_or_default
      group = Onduty::Group.asc(:position).first
      group ||= Onduty::Group.create!(name: "Default")
    end

  end
end
