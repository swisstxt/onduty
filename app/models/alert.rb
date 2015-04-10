module Onduty
  require 'securerandom'

  class Alert
    include Mongoid::Document
    include Mongoid::Timestamps

    field :uid, type: String
    field :host, type: String
    field :service, type: String
    field :notification_type, type: String
    field :service_state, type: String, default: "Unknown"
    field :last_alert_at, type: Time
    field :escalated_at, type: Time
    field :acknowledged_at, type: Time

    validates_presence_of :host
    validates_presence_of :service
    validates_presence_of :notification_type

    before_create :create_uid

    scope :created_after, ->(time) { where(:created_at.gt => time) }
    scope :acknowledged, ->{ where(:acknowledged_at.ne => nil) }
    scope :unacknowledged, ->{ where(acknowledged_at: nil) }

    def acknowledge!
      self.acknowledged_at = Alert.acknowledge(self.host, self.service)
      self.save!
    end

    def message
      "#{notification_type} - #{service} on #{host} is #{service_state}"
    end

    private

    def create_uid
      self.uid = SecureRandom.urlsafe_base64(8)
    end
  end
end
