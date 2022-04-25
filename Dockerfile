FROM ruby:2.7.6
# Common dependencies
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2 \
    curl \
    less \
    git \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

ENV APP_DIR=/home/app/html
RUN mkdir -p $APP_DIR $APP_DIR/log $APP_DIR/tmp/pids
WORKDIR $APP_DIR

RUN apt-get update && apt-get install default-libmysqlclient-dev -y && apt-get install tzdata -y

# Add NodeJS to sources list
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get update && apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get install yarn

RUN apt-get install -y shared-mime-info

COPY Gemfile      $APP_DIR/Gemfile
ADD Gemfile.lock  $APP_DIR/Gemfile.lock
RUN gem install bundler && bundle install

ADD package.json ./package.json
ADD yarn.lock    ./yarn.lock
RUN yarn install

COPY . .

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
