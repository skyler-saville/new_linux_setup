FROM debian:bookworm-slim

COPY linux_setup.sh version_check.sh /tmp/


RUN /tmp/linux_setup.sh 
RUN /tmp/version_check.sh