FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    file \
    gzip \
    && rm -rf /var/lib/apt/lists/*

RUN for i in $(seq 0 9); do useradd -m -s /bin/bash thief$i; done

RUN mkdir /var/run/sshd

COPY sshd_config /etc/ssh/sshd_config
COPY levels/ /levels/
RUN chmod +x /levels/*.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
