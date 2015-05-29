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

    validates_presence_of :first_name
    validates_presence_of :last_name

    validates :phone,
      presence: true,
      format: { with: /\+[0-9]+/ },
      length: { minimum: 10, maximum: 15 }

    def name
      "#{first_name} #{last_name}"
    end

    def duty_name
      Onduty::Duty.types[duty]
    end

  end
end
