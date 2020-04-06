FROM ruby:2.7.0
MAINTAINER john@hawthorn.email

RUN \
  curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - && \
  echo "deb http://deb.nodesource.com/node_10.x stretch main" | tee /etc/apt/sources.list.d/node.list && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - && \
  echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && \
  apt-get install -y build-essential nodejs yarn

RUN mkdir -p /app
WORKDIR /app

ENV \
  RAILS_LOG_TO_STDOUT=1 \
  RAILS_SERVE_STATIC_FILES=1 \
  RAILS_ENV=production

COPY Gemfile Gemfile.lock package.json yarn.lock ./
RUN \
  gem install bundler:1.17.3 && \
  bundle config build.nokogiri --use-system-libraries && \
  bundle install --jobs 20 --retry 5 --without development:test && \
  yarn

ADD . ./

RUN \
  SECRET_KEY_BASE=1 bundle exec rake assets:precompile

EXPOSE 8080

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "8080"]
