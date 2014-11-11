module Onduty
  require 'securerandom'

  class Alert < ActiveRecord::Base
    validates_presence_of :message
    validates_presence_of :host
    validates_presence_of :service

    before_create :create_uid

    scope :created_after, ->(time) { where("created_at > ?", time.utc) }
    scope :acknowledged, -> { where.not(acknowledged_at: nil) }
    scope :unacknowledged, -> { where(acknowledged_at: nil) }

    def acknowledge(icinga_cmd_path)
      if icinga_cmd_path
        now = Time.now.to_i
        %x['[#{now}] ACKNOWLEDGE_SVC_PROBLEM;#{self.host};#{self.service};1 \
 ;0;1;onduty;Acknowledged from Onduty #{now}' > #{icinga_cmd_path}]
      end
      self.acknowledged_at = Time.now
    end

    private

    def create_uid
     self.uid = SecureRandom.uuid
    end
  end
end
