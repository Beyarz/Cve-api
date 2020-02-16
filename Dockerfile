FROM ubuntu:20.04
WORKDIR /usr/src/cve-api/
COPY . .
HEALTHCHECK --interval=60s --timeout=30s --start-period=30s --retries=3 \
  CMD curl --fail http://0.0.0.0:4000/status || exit 1

RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y ruby \
  && apt-get install -y build-essential patch ruby-dev zlib1g-dev liblzma-dev \
  && apt-get install -y ruby-bundler \
  && bundle install \
  && echo "set :environment, :production" >> config/environment.rb

ENTRYPOINT [ "ruby", "rest.rb" ]
