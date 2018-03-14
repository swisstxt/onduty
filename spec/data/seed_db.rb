
# purge test-db
puts "Purging data from test db..."
Mongoid.purge!
puts "Seeding data to test db..."

# Groups
groups = [
  { name: "Application" },
  { name: "Infrastructure", position: 10 },
]

groups.each_with_index do |group, i|
  groups[i][:id] = Onduty::Group.create!(group)
end

# Contacts
contacts = [
  {
    first_name: "Ueli",
    last_name: "Beck",
    email: "ueli@beck.ch",
    phone: "+41324221444",
    group_id: groups[0][:id]
  },
  {
    first_name: "Anna",
    last_name: "Förster",
    email: "anna@foerster.ch",
    phone: "+41325221545",
    group_id: groups[1][:id]
  },
  {
    first_name: "Hans",
    last_name: "Älpler",
    email: "hans@vonderalp.ch",
    phone: "+41318562335",
    group_id: groups[0][:id]
  },
  {
    first_name: "Fränzi",
    last_name: "Schaffer",
    email: "f.schaffer@fmail.com",
    phone: "+41446552871",
    group_id: groups[1][:id]
  },
  {
    first_name: "Kari",
    last_name: "Schmid",
    email: "kari@schid.ch",
    phone: "+41788868954",
    group_id: groups[0][:id]
  },
]

contacts.each_with_index do |contact, i|
  contacts[i][:id] = Onduty::Contact.create!(contact)
end
