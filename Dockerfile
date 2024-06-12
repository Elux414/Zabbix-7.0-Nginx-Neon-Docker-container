FROM debian:latest

RUN wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-1+debian12_all.deb
RUN dpkg --force-bad-path -i zabbix-release_7.0-1+debian12_all.deb
RUN apt update && apt install zabbix-server-pgsql zabbix-frontend-php php8.2-pgsql zabbix-nginx-conf zabbix-sql-scripts postgresql-client supervisor -y
RUN apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY zabbix_server.conf /etc/zabbix/zabbix_server.conf
COPY zabbix.conf /etc/nginx/conf.d

RUN zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | psql "<ВСТАВИТЬ ССЫЛКУ> dbname=zabbix" -U zabbix

RUN chmod -R 777 /root

STOPSIGNAL SIGQUIT
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

EXPOSE 80 10051

VOLUME /var/log
VOLUME /usr/share/zabbix
