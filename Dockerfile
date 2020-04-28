FROM debian:latest

WORKDIR /drawio

ENV DRAWIO_VERSION "13.0.1"
RUN set -e; \
  apt-get update && apt-get install -y \
  libappindicator3-1 \
  libatspi2.0-0 \
  libasound2 \
  libgconf-2-4 \
  libgtk-3-0 \
  libnotify4 \
  libnss3 \
  libsecret-1-0 \
  libxss1 \
  libxtst6 \
  sgrep \
  wget \
  xdg-utils \
  xvfb; \
  wget -q https://github.com/jgraph/drawio-desktop/releases/download/v${DRAWIO_VERSION}/draw.io-amd64-${DRAWIO_VERSION}.deb \
  && apt-get install /drawio/draw.io-amd64-${DRAWIO_VERSION}.deb \
  && rm -f /drawio/draw.io-amd64-${DRAWIO_VERSION}.deb; \
  rm -rf /var/lib/apt/lists/*;

ENV DRAWIO_CLI "/opt/draw.io/drawio"
RUN useradd -ms /bin/bash drawio; usermod -aG sudo drawio
USER drawio

COPY --chown=drawio entrypoint.sh .
COPY --chown=drawio main.sh .
COPY --chown=drawio default.env .

WORKDIR /data
ENTRYPOINT [ "/drawio/entrypoint.sh" ]
CMD [ "" ]
