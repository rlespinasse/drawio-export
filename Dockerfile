FROM rlespinasse/drawio-cli:2.0.0

COPY entrypoint.sh /drawio/entrypoint.sh
COPY drawio-export.sh /drawio/drawio-export.sh
COPY drawio-default.env /drawio/drawio-default.env

WORKDIR /data
CMD [ "" ]
