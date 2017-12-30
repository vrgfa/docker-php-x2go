#FROM debian:jessie
FROM php:7.0-cli
MAINTAINER Ferenc Varga

# Please change this value to force the builders at Quay.io/Docker Hub
# to omit the cached Docker images. This will have the same effect to
# adding `--no-cache` to `docker build` command.
#
ENV DOCKERFILE_UPDATED 2017-12-29

RUN (apt-key adv --recv-keys --keyserver keys.gnupg.net E1F958385BFE2B6E)
RUN (echo 'deb http://packages.x2go.org/debian jessie main' | tee /etc/apt/sources.list.d/x2go.list)

RUN (apt-get update && \
     DEBIAN_FRONTEND=noninteractive apt-get install -y \
         sudo x2goserver x2goserver-xsession ttf-dejavu)

RUN (mkdir -p /var/run/sshd && \
     sed -ri 's/UseDNS yes/#UseDNS yes/g' /etc/ssh/sshd_config && \
     echo "UseDNS no" >> /etc/ssh/sshd_config)
#     sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
#     sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config)

# Create a user
RUN (useradd -m docker && \
     mkdir -p /home/docker/.ssh && \
     chmod 700 /home/docker/.ssh && \
     chown docker:docker /home/docker/.ssh && \
     mkdir -p /etc/sudoers.d)

ADD ./999-sudoers-docker /etc/sudoers.d/999-sudoers-docker
RUN chmod 440 /etc/sudoers.d/999-sudoers-docker

RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

# Startup script
ADD ./start-sshd.sh /root/start-sshd.sh
RUN chmod 744 /root/start-sshd.sh

#RUN ln -sf /usr/share/zoneinfo/Europe/Budapest /etc/localtime

EXPOSE 22
ENTRYPOINT ["/root/start-sshd.sh"]
