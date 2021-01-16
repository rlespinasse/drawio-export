FROM rlespinasse/drawio-cli:3.1.1

# install git for '--git-ref' option
RUN set -e; \
  apt-get update && apt-get install -y --no-install-recommends \
  git=1:2.20.1-2+deb10u3 \
  && rm -rf /var/lib/apt/lists/*;

# keep runner.sh from drawio-cli base image
RUN mv runner.sh cli-runner.sh

# setup the drawio-export files
COPY runner.sh .
COPY runner.env .

WORKDIR /data
CMD [ "" ]
