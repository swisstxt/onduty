module Onduty
  class Duty
    def self.types
      {
        0 => "off-duty",
        1 => "primary",
        2 => "escalation"
      }
    end
  end
end
