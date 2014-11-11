module Onduty
  class ZendeskNotification < Notification
    require 'zendesk_api'

    def name
      "Onduty Zendesk Notification"
    end

    def valid_configuration?
      @settings.zendesk_url && @settings.zendesk_username && @settings.zendesk_token
    end

    def trigger
      # only trigger at first alert
      unless @alert.last_alert_at
        print "alert_#{@alert_id}: Creating Zendesk ticket..."
        client = ZendeskAPI::Client.new do |config|
          config.url      = @settings.zendesk_url
          config.username = @settings.zendesk_username
          config.token    = @settings.zendesk_token
          # Logger prints to STDERR by default, to e.g. print to stdout:
          require 'logger'
          config.logger = Logger.new(STDOUT)

          # Changes Faraday adapter
          # config.adapter = :patron

          # Merged with the default client options hash
          # config.client_options = { :ssl => false }

          # When getting the error 'hostname does not match the server certificate'
          # use the API at https://yoursubdomain.zendesk.com/api/v2
        end
        ZendeskAPI::Ticket.create(
          client, :subject => "Test Ticket",
          :comment => { :value => "This is a test" },
          :submitter_id => client.current_user.id, :priority => "urgent"
        )
        puts "\t\t[OK]"
      end
    end
  end
end
