FROM rlespinasse/drawio-cli:2.1.0

# keep runner.sh from drawio-cli base image
RUN mv runner.sh cli-runner.sh

# setup the drawio-export files
COPY runner.sh .
COPY runner.env .

WORKDIR /data
CMD [ "" ]
