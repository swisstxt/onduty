module Onduty

  class ContactFile
    def initialize(file = './files/pikettnumbers.txt')
      @file = file
    end

    def on_duty
      contacts.find{|c| c[:status] == '1'}
    end

    def contacts
      @contacts ||= load_contacts
    end

    private

    def load_contacts
      contacts = []
      IO.foreach(@file) do |raw_line|
        line = raw_line.split(";")
        contacts << {
          status: line[0],
          number: line[1].gsub(/^00/, '+'),
          full_name: line[2],
          username: line[3]
        }
      end
      contacts
    end

  end

end
