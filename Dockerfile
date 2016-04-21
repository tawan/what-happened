FROM tawan/what-happened-base:ruby-2.3

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/Gemfile

RUN bundle install
