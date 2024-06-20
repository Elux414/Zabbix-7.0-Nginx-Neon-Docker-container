FROM debian:latest

ARG DB_PASSWORD
ARG NEON_URL

RUN apt update && apt install wget curl -y
RUN curl -fsSL https://tailscale.com/install.sh | sh
RUN wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-1+debian12_all.deb && \
    dpkg --force-bad-path -i zabbix-release_7.0-1+debian12_all.deb
RUN apt update && apt install zabbix-server-pgsql zabbix-frontend-php php8.2-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent postgresql-client supervisor python3 -y
RUN apt update && apt install -y locales
RUN sed -i '/ru_RU.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen ru_RU.UTF-8
ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU:ru
ENV LC_ALL ru_RU.UTF-8

RUN apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN rm /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/zabbix/zabbix_server.conf
COPY zabbix_server.conf /etc/zabbix/zabbix_server.conf
RUN rm /etc/nginx/conf.d/zabbix.conf
COPY zabbix.conf /etc/nginx/conf.d/zabbix.conf
RUN rm /etc/zabbix/zabbix_agentd.conf
COPY zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf
COPY replace_zb_conf.py /usr/local/bin/replace_zb_conf.py
RUN chmod +x /usr/local/bin/replace_config.py

ARG DB_HOST
ARG DB_PASSWORD
ENV DB_HOST=${DB_HOST}
ENV DB_PASSWORD=${DB_PASSWORD}

RUN python3 /usr/local/bin/replace_zb_conf.py

RUN mkdir -p /etc/supervisor/conf.d

# ENV PGPASSWORD=${DB_PASSWORD}
# ENV NEON_URL=${NEON_URL}
# RUN zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | psql "sslmode=require host=$NEON_URL dbname=zabbix" -U zabbix

RUN chmod -R 777 /root

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY setup_tailscale.sh /usr/local/bin/setup_tailscale.sh
RUN chmod +x /usr/local/bin/setup_tailscale.sh

ARG AUTH_KEY
ENV TAILSCALE_AUTH_KEY=${AUTH_KEY}

STOPSIGNAL SIGQUIT
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

EXPOSE 80 1055 10051 41641

VOLUME /var/log
VOLUME /usr/share/zabbix
