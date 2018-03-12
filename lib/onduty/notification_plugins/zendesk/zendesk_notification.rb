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
      unless alert.last_alert_at
        client = ZendeskAPI::Client.new do |config|
          config.url      = @settings.zendesk_url
          config.username = @settings.zendesk_username
          config.token    = @settings.zendesk_token
        end
        comment = Erubis::Eruby.new(
          File.read(File.join(File.dirname(__FILE__), 'zendesk_notification.erb'))
        ).result(
          alert: @alert, contact: @contact,
          acknowledge_url: acknowledge_url(html_link: true)
        )
        ticket = ZendeskAPI::Ticket.new(client,
          subject: "[Alert #{@alert.id}] Alert from onduty",
          comment: { value: comment },
          submitter_id: client.current_user.id,
          assignee_email: @contact.email,
          priority: "normal",
          tags: %w(onduty)
        )
        if ticket.save
          logger.info "Created Zendesk ticket for alert with ID #{@alert.id}."
        else
          logger.error "Zendeks ticket can't be saved: #{ticket.errors}"
        end
      else
        logger.info "Skipping Zendesk ticket for alert with ID #{@alert.id} because the alert is not new."
      end
    rescue => e
      logger.error "Error creating Zendesk ticket: #{e.message}"
      if ENV['APP_ENV'] == 'development'
        logger.info "Backtrace: #{e.backtrace}"
      end
    end
  end
end
