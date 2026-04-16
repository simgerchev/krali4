FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    file \
    && rm -rf /var/lib/apt/lists/*

# Create level users with no password initially (entrypoint sets them)
RUN for i in $(seq 0 5); do \
    useradd -m -s /bin/bash level$i; \
done

# sshd needs this dir
RUN mkdir /var/run/sshd

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
