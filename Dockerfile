FROM debian:jessie
MAINTAINER SneakyScampi

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y apt-utils
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y postfix rsyslog postfix-policyd-spf-python iptables git vim

# Copy Assets
COPY assets/openssl-templates /usr/local/share/openvpn/
COPY assets/etc /etc/

RUN git clone https://github.com/alexdw1/openssl-tools.git /tmp/openssl-tools && cd /tmp/openssl-tools && ./install.sh && rm -rf /tmp/openssl-tools

# add/modify services in /etc/postfix/master.cf

RUN postconf -eM policy-spf/unix="policy-spf  unix  -       n       n       -       -       spawn\
     user=nobody argv=/usr/bin/policyd-spf"

# Add startup script
ADD assets/startup.sh /opt/startup.sh
RUN chmod a+x /opt/startup.sh

VOLUME /opt/ssl

# Docker startup
#EXPOSE 25 - We don't need to expose port 25 as we access the service via the internal network address fwd from our dockerVPN
ENTRYPOINT ["/opt/startup.sh"]
CMD ["-h"]
