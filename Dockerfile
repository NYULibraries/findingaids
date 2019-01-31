FROM ruby:2.5.3-alpine

ENV DOCKER true
ENV INSTALL_PATH /app

RUN addgroup -g 1000 -S docker && \
  adduser -u 1000 -S -G docker docker

WORKDIR $INSTALL_PATH
RUN chown docker:docker .

# bundle install
COPY --chown=docker:docker bin/ bin/
COPY --chown=docker:docker Gemfile Gemfile.lock ./
ARG RUN_PACKAGES="ca-certificates fontconfig mariadb-dev nodejs tzdata"
ARG BUILD_PACKAGES="ruby-dev build-base linux-headers mysql-dev python git"
RUN apk add --no-cache --update $RUN_PACKAGES $BUILD_PACKAGES \
  && gem install bundler -v '1.16.6' \
  && bundle config --local github.https true \
  && bundle install --without no_docker --jobs 20 --retry 5 \
  && rm -rf /root/.bundle && rm -rf /root/.gem \
  && rm -rf /usr/local/bundle/cache \
  && apk del $BUILD_PACKAGES \
  && chown -R docker:docker /usr/local/bundle

# precompile assets; use temporary secret token to silence error, real token set at runtime
USER docker
COPY --chown=docker:docker . .
RUN SECRET_TOKEN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1) \
  && SECRET_KEY_BASE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1) \
  RAILS_RELATIVE_URL_ROOT=/search RAILS_ENV=production bin/rails assets:precompile

# run microscanner
USER root
ARG AQUA_MICROSCANNER_TOKEN
RUN wget -O /microscanner https://get.aquasec.com/microscanner && \
  chmod +x /microscanner && \
  /microscanner ${AQUA_MICROSCANNER_TOKEN} && \
  rm -rf /microscanner

USER docker
EXPOSE 9292

CMD ./scripts/start.sh development
