module Onduty
  class Contact < ActiveRecord::Base
    validates_presence_of :first_name
    validates_presence_of :last_name
    #validates_presence_of :phone
    validates :phone,
      presence: true,
      format: { with: /\+[0-9]+/ },
      length: { minimum: 10, maximum: 15 }

    has_one :duty

    def self.states
      {0 => 'off-duty', 1 => 'on-duty', 2 => 'escalation'}
    end

    def name
      "#{first_name} #{last_name}"
    end
  end
end
