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

    # first_name + last_name combinations must be unique as well as emails
    validates_uniqueness_of :last_name, scope: :first_name
    validates_uniqueness_of :email

    before_save :strip_phone_number, if: :changed?

    validates :phone,
      presence: true,
      phone: {
        valid: true,
        types: [:mobile],
        countries: [:ch, :li],
        message: "must be a valid <b>mobile</b> number in Switzerland or Liechtenstein",
      }

    def name
      "#{first_name} #{last_name}"
    end

    def duty_name
      Onduty::Duty.types[duty]
    end

    protected

    def strip_phone_number
      self.phone.gsub!(/[^\d\+]*/, '')
    end

  end
end
