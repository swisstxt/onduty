# OnDuty

![OnDuty](public/images/onduty.png)

Manage OnDuty contacts and trigger alarms via phone, SMS, Slack and Email.

## Setup

### Depedencies

  - Runtime: up from Ruby 1.9.3 required, 2.0+ is recommended.
  - Database: MongoDB
  - Alert Acknowledgement: Icinga2
  - Phone and SMS alerts: Twilio

Dependencies are managed using bundler (install the bundler gem if you don't have it).

```bash
bundle install
```

### Configure the database connection

OnDuty uses MongoDB as backend.
Create a configuration file named config/mongoid.yml (see config/mongoid.example.yml).

### Create your own configuration

Create your own configuration and adapt it.

The following locations are checked for a config file (in this order):
   * /etc/onduty.yml
   * /etc/onduty/onduty.yml
   * config/onduty.yml
   * config/onduty.example.yml

```bash
cp config/onduty.example.yml config/onduty.yml
vi config/onduty.yml
```

### Run with Docker

Build the image:

```bash
docker build -t onduty:latest .
```

Run it together with mongodb:

```bash
docker-compose up
```

### Access Control

OnDuty protects access using basic auth, when you configure "admin_user" and "admin_password" in your configuration file.

The alert acknowledge and twiml methods are protected by alert UID.

### Icinga2 acknowledge

Configure the Icinga2 API:

```yaml
icinga2_api_path: https://localhost:5665/v1
icinga2_user: admin
icinga2_password: icinga
```

## Run the server

OnDuty is a Sinatra Webapp and can be started using any Rack compatible webserver.

From the application base directory:

```bash
rackup config.ru
```

...or run it directly with Puma:

```bash
puma config.ru -p 80
```

## CLI

See `bundle exec bin/onduty-cli` for a cli help.

## Plugins

The following plugins are available:
  - VoiceNotification (using Twilio)
  - SmsNotification (using Twilio)
  - MailNotification
  - SlackNotification
  - ZendeskNotification

Plugins can be enabled/disabled within the configuration file.

This is the default configuration:

```bash
notification_plugins:
  - VoiceNotification
  - SmsNotification
  - MailNotification
```

Check the plugins state using the onduty-cli:

```bash
bundle exec bin/onduty-cli plugins
```

### Plugin Configuration Parameters

#### VoiceNotification and SmsNotification

In order to use the VoiceNotification and SmsNotification plugins you have to configure the following twilio account parameters:

```yaml
# To find these visit https://www.twilio.com/user/account
account_sid: "12677267267267267627676276276276"
auth_token:  "32324323424242424242424242424242"
from_number: "+12345678910"
```

#### MailNotification

```yaml
email_sender: 'alert@onduty'
smtp_options:
  :address: mail.example.com
```

#### SlackNotification

  1. Add a [new bot](https://my.slack.com/services/new/bot) on your Slack account and take note of the API token.
  2. Invite your new bot to the channel your are going to configure within OnDuty.

```yaml
slack_api_token: slack-api-token
slack_channel: '#general'
```

#### ZendeskNotification

```yaml
zendesk_url: https://yoursubdomain.zendesk.com/api/v2
zendesk_username: you@yourdomain.com
zendesk_token: you-zendesk-token
```

# Trigger alerts from external sources

The following example shows how to create an alert using cURL and JSON payload:

```bash
curl -v -i -X POST -H "Content-Type: application/json" \
--data '{"alert":{"name":"test_alert","services":[{"name":"service1","host":"host1"},{"name":"service2","host":"host2"}]},"trigger_alert":"true"}' \ 'http://admin:password@127.0.0.1:9393/alerts/new.json'
```
