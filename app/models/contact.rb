module Onduty
  class Contact
    include Mongoid::Document
    include Mongoid::Timestamps

    field :first_name, type: String
    field :last_name, type: String
    field :phone, type: String
    field :email, type: String
    field :alert_by_email, type: Integer, default: 1
    field :alert_by_sms, type: Integer, default: 1
    field :duty, default: 0, type: Integer

    belongs_to :group

    validates_presence_of :first_name
    validates_presence_of :last_name

    before_save :strip_phone_number, if: :changed?

    validates :phone,
      presence: true,
      format: {
        with: /\A[+]{1}[0-9]{2}\s?[0-9]{2}\s?[0-9]{3}\s?[0-9]{2}\s?[0-9]{2}\z/
      }

    def name
      "#{first_name} #{last_name}"
    end

    def duty_name
      Onduty::Duty.types[duty]
    end

    protected

    def strip_phone_number
      self.phone.gsub!(' ', '')
    end

  end
end
