
require './app/models/duty'

# Create default duty types
# make sure we set the id's manually
[
  {id: 1, name: 'onduty'},
  {id: 2, name: 'escalation'}
].each do |duty|
  Onduty::Duty.new do |d|
    d.id = duty[:id]
    d.name = duty[:name]
    d.save
  end
end
