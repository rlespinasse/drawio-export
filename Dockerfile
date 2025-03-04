FROM rust:bullseye as drawio-exporter-installer

RUN cargo install drawio-exporter --version 1.3.0

FROM rlespinasse/drawio-desktop-headless:v1.40.0

WORKDIR /opt/drawio-exporter
COPY --from=drawio-exporter-installer /usr/local/cargo/bin/drawio-exporter .
COPY src/* ./

# disable timeout capabilities since it's a batch
ENV DRAWIO_DESKTOP_COMMAND_TIMEOUT 0
ENV DRAWIO_DESKTOP_RUNNER_COMMAND_LINE "/opt/drawio-exporter/runner.sh"
ENV DRAWIO_DESKTOP_EXECUTABLE_PATH /opt/drawio-exporter/drawio-exporter

WORKDIR /data
CMD [ "" ]
