module Onduty
  class ZendeskNotification < Notification
    require 'zendesk_api'

    def name
      "Onduty Zendesk Notification"
    end

    def valid_configuration?
      @settings.zendesk_url && @settings.zendesk_username && @settings.zendesk_token
    end

    def client
      @client ||= ZendeskAPI::Client.new do |config|
        config.url      = @settings.zendesk_url
        config.username = @settings.zendesk_username
        config.token    = @settings.zendesk_token
      end
    end

    def assignee
      @assignee ||= (client.users.search(query: @contact.email).first || client.current_user)
    end

    def assignee_is_member_of_default_group
      assignee.group_memberships.any? { |u| u.user_id == assignee.id }
    end

    def ticket_group_id
      if @settings.zendesk_group_id && assignee_is_member_of_default_group
        @settings.zendesk_group_id
      else
        assignee.default_group_id
      end
    end

    def ticket_group
      @ticket_group ||= client.groups.find(id: ticket_group_id)
    end

    def ticket_subject
      subject = "Business Process Alert"
      if alert.group
        "[Onduty - #{alert.group.name}] " + subject
      else
        "[Onduty] " + subject
      end
    end

    def ticket_html_description
      Erubis::Eruby.new(
        File.read(File.join(File.dirname(__FILE__), 'zendesk_notification.erb'))
      ).result(
        alert: @alert,
        contact: @contact,
        acknowledge_url: acknowledge_url(html_link: true),
        alert_url: detail_url,
        monitoring_base_url: @settings.icinga2_web_path,
      )
    end

    def trigger
      # only trigger at first alert
      unless alert.last_alert_at
        ticket = client.tickets.create(
          subject: ticket_subject,
          comment: { html_body: ticket_html_description },
          submitter_id: client.current_user.id,
          assignee_id: assignee.id,
          group_id: ticket_group_id,
          priority: "urgent",
          tags: %w(onduty)
        )
        if ticket.save
          logger.info "Created Zendesk ticket for alert with ID #{@alert.id}, assigned to '#{ticket_group.name}/#{assignee.name}'."
        else
          logger.error "Zendesk ticket can't be saved: #{ticket.errors}"
        end
      else
        logger.info "Skipping Zendesk ticket for alert with ID #{@alert.id} because the alert is not new."
      end
    rescue => e
      logger.error "Error creating Zendesk ticket: #{e.message}"
      unless ENV["APP_ENV"] == "production"
        logger.info "Backtrace: #{e.backtrace}"
      end
    end
  end
end
