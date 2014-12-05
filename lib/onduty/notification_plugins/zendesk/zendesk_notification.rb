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
        client = ZendeskAPI::Client.new do |config|
          config.url      = @settings.zendesk_url
          config.username = @settings.zendesk_username
          config.token    = @settings.zendesk_token
        end
        comment = Erubis::Eruby.new(
          File.read(File.join(File.dirname(__FILE__), 'zendesk_notification.erb'))
        ).result(
          alert: @alert,
          contact: @contact,
          acknowledge_url: acknowledge_url(html_link: true)
        )
        ZendeskAPI::Ticket.create(
          client, subject: "[Alert #{@alert_id}] Alert from onduty",
          comment: { value: comment },
          submitter_id: client.current_user.id, priority: "urgent"
        )
        logger.info "Created Zendesk ticket for alert with ID #{@alert_id}."
      else
        logger.info "Skipping Zendesk ticket for alert with ID #{@alert_id} because the alert is not new."
      end
    rescue => e
      logger.error "Error creating Zendesk ticket: #{e.message}"
    end
  end
end
