FROM haproxy:1.7

ENV HAPROXY_USER haproxy

RUN groupadd --system ${HAPROXY_USER} && \
  useradd --system --gid ${HAPROXY_USER} ${HAPROXY_USER} && \
  mkdir --parents /var/lib/${HAPROXY_USER} && \
  chown -R ${HAPROXY_USER}:${HAPROXY_USER} /var/lib/${HAPROXY_USER}

RUN mkdir -p /etc/ssl/default

RUN apt-get update
RUN apt-get install -y rsyslog
RUN /etc/init.d/rsyslog restart
