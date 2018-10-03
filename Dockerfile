FROM ubuntu
MAINTAINER blaize.net

RUN apt-get update \
  && apt-get install -y ruby \
  && rm -rf /var/lib/apt/lists/*

ADD build.sh /build.sh
RUN chmod +x /build.sh
RUN /bin/bash -c "source /build.sh"

ADD templates/bin /usr/local/bin
ADD templates/nginx.conf.erb /usr/local/nginx/conf/nginx.conf.erb
ADD modsec_includes.conf /usr/local/nginx/conf/modsec_includes.conf
ADD templates/modsecurity.conf /usr/local/nginx/conf/modsecurity.conf
ADD crs-setup.conf /usr/local/nginx/conf/rules/crs-setup.conf

CMD ["/usr/local/bin/nginx-wrapper"]

EXPOSE 80
