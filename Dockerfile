FROM ruby:3.0
MAINTAINER john@hawthorn.email

RUN \
  apt-get update && \
  apt-get install -y build-essential && \
  apt-get clean

RUN mkdir -p /app
WORKDIR /app

ENV \
  RAILS_LOG_TO_STDOUT=1 \
  RAILS_SERVE_STATIC_FILES=1 \
  RAILS_ENV=production

COPY Gemfile Gemfile.lock ./
RUN \
  gem install bundler:1.17.3 && \
  bundle config build.nokogiri --use-system-libraries && \
  bundle config set --local without 'development:test' && \
  bundle install --jobs 20 --retry 5

ADD . ./

RUN \
  bundle exec rake assets:precompile

EXPOSE 3000
VOLUME /data

ARG REVISION
ENV REVISION=$REVISION

CMD ["/bin/bash", "/app/docker_init.sh"]
