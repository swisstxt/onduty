# OnDuty

![OnDuty](public/images/onduty.png)

Manage OnDuty contacts and trigger alarms via phone, SMS, Slack and Email.

## Setup

### Depedencies

  - Runtime: Ruby 2.2+ required
  - Database: MongoDB
  - Alert Acknowledgement: Icinga2
  - Phone and SMS alerts: Twilio

Dependencies are managed using bundler (install the bundler gem if you don't have it).

```bash
bundle install
```

### Base configuration

```bash
# Application environment, i.e. production, test, development
APP_ENV=development
# MongoDB connection URI
MONGODB_URI=mongodb://mongodbserver:27017/onduty
# Application base URL
ONDUTY_BASE_URL=http://localhost:3000/
# How many alerts are required to trigger a notification
ONDUTY_ALERT_LIMIT=2
# When to consider an existing alert as new (in seconds)
# when the time is below this value the count of an alert goes up
ONDUTY_ALERT_THRESHOLD=7200

# Optionally set some constraints to the phone numbers of the Onduty Contacts,
# with comma separated (wihout spaces) code countries and phone types
# (see https://github.com/daddyz/phonelib#getting-started for more details)
# ONDUTY_PHONE_COUNTRIES=ch
# ONDUTY_PHONE_TYPES=fixed_line,mobile
```

### Build & Run with Docker

Build the image:

```bash
docker build -t onduty:latest .
```

Run it together with mongodb:

```bash
docker-compose up
```

### Access Control

OnDuty protects access using basic auth, when you set the ENV variables ONDUTY_ADMIN_USER and ONDUTY_ADMIN_PASSWORD:

```bash
ONDUTY_ADMIN_USER=admin
ONDUTY_ADMIN_PASSWORD=password
```

The alert acknowledge and twiml methods are protected by alert UID.

### Icinga2 acknowledge

Configure the Icinga2 API:

```bash
ONDUTY_ICINGA2_API_PATH=https://icinga2.local:5665/v1
ONDUTY_ICINGA2_WEB_PATH=http://icinga2.local
ONDUTY_ICINGA2_USER=icinga2-onduty
ONDUTY_ICINGA2_PASSWORD=icinga2-password
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

## JSON API

You can get JSON output for several resources.

Example for getting the primary onduty contact for group "Infrastructure":
```bash
GET /contacts.json?duty=primary&group_name=Infrastructure
```

Getting all groups:
```bash
GET /groups.json
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

Plugins can be enabled/disabled using ENV.

This is the default configuration:

```bash
ONDUTY_NOTIFICATION_PLUGINS=VoiceNotification,MailNotification
```

Check the plugins state using the onduty-cli:

```bash
bundle exec bin/onduty-cli plugins
```

### Plugin Configuration Parameters

#### Twilio VoiceNotification and SmsNotification

In order to use the VoiceNotification and SmsNotification plugins you have to configure the following twilio account parameters:

```bash
ONDUTY_TWILIO_ACCOUNT_SID=<account-sid>
ONDUTY_TWILIO_ACCOUNT_TOKEN=<account-token>
ONDUTY_TWILIO_FROM_NUMBER=+411235678
```

#### MailNotification

```bash
ONDUTY_EMAIL_SENDER=onduty@onduty.local
ONDUTY_SMTP_ADDRESS=smtprelay.onduty.local
```

#### SlackNotification

  1. Add a [new bot](https://my.slack.com/services/new/bot) on your Slack account and take note of the API token.
  2. Invite your new bot to the channel your are going to configure within OnDuty.

```bash
ONDUTY_SLACK_API_TOKEN=<slack-api-token>
ONDUTY_SLACK_CHANNEL=#onduty-test
```

#### ZendeskNotification

```bash
ONDUTY_ZENDESK_URL=https://<your-workspace>.zendesk.com/api/v2
ONDUTY_ZENDESK_USERNAME=onduty@onduty.local
ONDUTY_ZENDESK_TOKEN=<zendesk-token>
# ONDUTY_ZENDESK_GROUP_ID=<zendesk-group-id>
# ONDUTY_ZENDESK_SKIPPED_GROUPS=RedTeam,BlueTeam
```

When `ONDUTY_ZENDESK_GROUP_ID` is not defined, the assignee's default group id will be used.

When `ONDUTY_ZENDESK_SKIPPED_GROUPS` is defined (with _existing_ group names as comma-separated list), no Zendesk tickets will be created for alerts of these groups.

# Trigger alerts from external sources

The following example shows how to create an alert using cURL and JSON payload:

```bash
curl -v -i -X POST -H "Content-Type: application/json" \
--data '{"alert":{"name":"test_alert","group":"Test","services":[{"name":"service1","host":"host1"},{"name":"service2","host":"host2"}]},"force":"false"}' \ 'http://admin:password@127.0.0.1:3000/alerts/new.json'
```
