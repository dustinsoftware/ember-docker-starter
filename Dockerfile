FROM node:10 AS node-build

RUN apt-get update && apt-get install -y lsyncd nano supervisor

RUN mkdir -p /var/log/supervisor

# Chrome install steps taken from https://hub.docker.com/r/browserless/chrome/dockerfile
RUN apt-get install -y \
  fonts-liberation \
  fontconfig \
  libappindicator3-1 \
  libasound2 \
  libatk1.0-0 \
  libgtk-3-0 \
  libnspr4 \
  libx11-6 \
  libx11-xcb1 \
  libxss1 \
  libxtst6 \
  libnss3 \
  lsb-release \
  xdg-utils \
  wget \
  xvfb \
  curl &&\
  # Fonts
  fc-cache -f -v

RUN cd /tmp &&\
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&\
    dpkg -i google-chrome-stable_current_amd64.deb && rm -rf /tmp/*

RUN mkdir -p /app/dist

RUN groupadd -r user \
  && useradd --create-home -g user -G audio,video user \
  && chown -R user:user /app

RUN npm i -g ember-cli

USER user

WORKDIR /app

COPY --chown=user:user supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY --chown=user:user lsyncd.conf.lua /etc/lsyncd/lsyncd.conf.lua

# Copy over package manifests first, so that other source code changes don't cause packages to be
# re-restored. If a new dependency is added, the container needs to be re-built.
COPY --chown=user:user ./package.json .
COPY --chown=user:user ./yarn.lock .

RUN yarn install --frozen-lockfile

# Copy over the rest of the source.
# Note: The source will be kept in sync when the Docker container is running!
COPY --chown=user:user . .

# Allow running tests as a part of the docker build
ARG RUN_TESTS
ARG SKIP_FIRST_BUILD
RUN if [ "$RUN_TESTS" ]; then \
    ember test --launch Chrome; \
  elif [ ! "$SKIP_FIRST_BUILD" ]; then \
    ember build; \
  fi

# Future Javascript builds happen inside the Docker container run.
# This is because volumes can't be accessed during the docker build, and ember serve
# should be notified right away when source code changes *without* requiring a container rebuild.
# See docker-compose for volume mounts.

CMD ["/usr/bin/supervisord", "-c", "/app/supervisord.conf"]
