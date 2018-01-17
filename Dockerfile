FROM ruby:2.3.4-alpine

# Rails Setup
RUN apk update && apk upgrade && apk add --update --no-cache sqlite-dev nodejs tzdata alpine-sdk

RUN mkdir /app
WORKDIR /app

ENV RAILS_ENV production

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

# Insstalling nokogiri gem
RUN apk add --no-cache --virtual build-dependencies build-base && \
    apk add --no-cache libxml2-dev libxslt-dev && \
    gem install nokogiri -- --use-system-libraries \
    --with-xml2-config=/usr/bin/xml2-config \
    --with-xslt-config=/usr/bin/xslt-config && \
    apk del build-dependencies
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install --path vendor/bundle --without development test
ADD . /app

RUN bundle exec rake db:setup
RUN bundle exec rake assets:precompile

EXPOSE 3000
