# Onduty

Manage onduty contacts and alarming.

## Setup

### Depedencies

Ruby 1.9.3 or greater is required to run the application.

Dependencies are managed using bundler (install the bundler gem if you don't have it).

```bash
bundle install
```

### Initialize the database

```bash
bundle exec rake db:setup
```

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

## TODO

This is an alpha release - still a lot to do:
  * cli
    * alert creation
    * triggering alerts and escalation
  * mail alerts
  * authentication
