FROM ruby:2.6-alpine

RUN apk --update add --virtual build-dependencies ruby-dev build-base

ENV APP_HOME /app

COPY Gemfile* $APP_HOME/
WORKDIR $APP_HOME
RUN gem install bundler --no-document
RUN bundle install -j 20
RUN apk del build-dependencies

COPY . $APP_HOME

RUN chown -R nobody:nogroup $APP_HOME
USER nobody

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-p", "3000", "-t",  "2:2"]
