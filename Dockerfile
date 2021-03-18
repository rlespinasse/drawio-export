FROM rlespinasse/drawio-desktop-headless:1.0.1

# install git for '--git-ref' option
RUN set -e; \
  apt-get update && apt-get install -y --no-install-recommends \
  git=1:2.20.1-2+deb10u3 \
  && rm -rf /var/lib/apt/lists/*;

# setup the drawio-export files
COPY export.sh .
COPY export.env .

# disable timeout capabilities since it's a batch
ENV DRAWIO_DESKTOP_COMMAND_TIMEOUT 0
ENV DRAWIO_DESKTOP_RUNNER_COMMAND_LINE "/opt/drawio-desktop/export.sh"

WORKDIR /data
CMD [ "" ]
