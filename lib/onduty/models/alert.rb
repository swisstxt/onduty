require 'securerandom'

class Alert < ActiveRecord::Base
  validates_presence_of :message

  before_create :create_uid

  scope :created_after, ->(time) { where("created_at < ?", time) }
  scope :acknowledged, -> { where.not(acknowledged_at: nil) }
  scope :unacknowledged, -> { where(acknowledged_at: nil) }

  private

  def create_uid
   self.uid = SecureRandom.uuid
  end
end
