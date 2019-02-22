FROM ruby:2.6-alpine

RUN apk --update add --virtual build-dependencies ruby-dev build-base

# Ugly hack to display date/time values in local time
# Ideally, this should be handled at the Ruby Application level
RUN apk add tzdata && \
    cp /usr/share/zoneinfo/Europe/Zurich /etc/localtime && \
    echo "Europe/Zurich" > /etc/timezone && \
    apk del tzdata

ENV APP_USER_ID 1000
ENV APP_USER onduty
ENV APP_HOME /$APP_USER

# Note that `adduser` on Alpine automatically creates a group
# with same name and id as the user being created.
# Account `home` is intentionally not set to $APP_HOME!
RUN adduser -D -u $APP_USER_ID $APP_USER
USER $APP_USER

COPY Gemfile* $APP_HOME/
WORKDIR $APP_HOME
RUN gem install bundler --no-document
RUN bundle install -j 20

COPY . $APP_HOME

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-p", "3000", "-t",  "2:2"]
