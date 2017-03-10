module Onduty
  require 'securerandom'

  class Alert
    include Mongoid::Document
    include Mongoid::Timestamps

    field :uid, type: String,
      default: ->{ SecureRandom.urlsafe_base64(32) }
    field :name, type: String
    field :notification_type, type: String, default: "Alert"
    field :last_alert_at, type: Time
    field :escalated_at, type: Time
    field :acknowledged_at, type: Time
    field :count, type: Integer, default: 0

    embeds_many :services

    validates_presence_of :name

    scope :created_after, ->(time) { where(:created_at.gt => time) }
    scope :acknowledged, ->{ where(:acknowledged_at.ne => nil) }
    scope :unacknowledged, ->{ where(acknowledged_at: nil) }

    def services_string=(str)
      str.lines.each do |s_str|
        self.services << Service.new(
          host: s_str.split('!').first,
          name: s_str.split('!').last
        )
      end
    end

    def services_string
      self.services.each.map do |service|
        service.name
      end.join("\n")
    end

    def acknowledge!
      self.acknowledged_at = Time.now
      self.save!
    end

    def acknowledged?
      self.acknowledged_at != nil
    end

    def message
      [notification_type, name].join(' - ')
    end

  end
end
