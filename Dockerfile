FROM ruby:2.4.2-alpine3.6
ADD Gemfile /app/
ADD Gemfile.lock /app/
RUN apk --update add --virtual build-dependencies ruby-dev build-base && \
    gem install bundler --no-ri --no-rdoc && \
    cd /app ; bundle install --without development test && \
    apk del build-dependencies
ADD . /app
RUN chown -R nobody:nogroup /app
USER nobody
ENV RACK_ENV development
EXPOSE 9292
WORKDIR /app
CMD ["bundle", "exec", "puma", "-p", "3000"]
