module Onduty
  class Duty < ActiveRecord::Base
     belongs_to :contact
  end
end
