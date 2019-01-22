FROM ruby:2.6-alpine
ADD Gemfile /app/
ADD Gemfile.lock /app/
RUN apk --update add --virtual build-dependencies ruby-dev build-base && \
    gem install bundler -no-ri-no-rdoc && \
    cd /app ; bundle install --without development test && \
    apk del build-dependencies
ADD . /app
RUN chown -R nobody:nogroup /app
USER nobody
EXPOSE 3000
WORKDIR /app
CMD ["bundle", "exec", "puma", "-p", "3000", "-t",  "2:2"]
