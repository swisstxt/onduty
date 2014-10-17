class Contact < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :phone

  def self.states
    {0 => '', 1 => 'on-duty', 2 => 'escalation'}
  end
end
