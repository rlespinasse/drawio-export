FROM rlespinasse/drawio-cli:1.0.0

WORKDIR /drawio

COPY entrypoint-export.sh .
COPY main.sh .
COPY default.env .

WORKDIR /data
ENTRYPOINT [ "/drawio/entrypoint-export.sh" ]
CMD [ "" ]
