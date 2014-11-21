# Onduty

Manage onduty contacts and alarming.

## Setup

### Depedencies

Ruby 1.9.3 or greater is required to run the application.

Dependencies are managed using bundler (install the bundler gem if you don't have it).

```bash
bundle install
```

### Configure the database connection

Onduty uses MongoDB as backend.
Creat a configuration file named config/mongoid.yml. See config/mongoid.example.yml for inspiration.

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

### Security
At the moment the application just provides basic auth, when you configure "admin_user" and "admin_password" in your configuration file.

The alert acknowledge and twiml methods are protected by alert UID.

### Icinga/Nagios acknowledge

Set the 'icinga_cmd_path' variable in your configuration in order to acknowledge alerts in Icinga or Nagios.

```bash
icinga_cmd_path: /var/icinga/rw/icinga.cmd
```

## Run the server

Onduty is a Sinatra Webapp and can be started using any Rack compatible webserver.

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
  - ZendeskNotification

Plugins can be enabled/disables using the configuration file.

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

#### ZendeskNotification

```yaml
zendesk_url: https://yoursubdomain.zendesk.com/api/v2
zendesk_username: you@yourdomain.com
zendesk_token: you-zendesk-token
```
