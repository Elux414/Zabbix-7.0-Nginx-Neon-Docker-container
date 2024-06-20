#!/bin/bash

# Запуск Tailscale daemon и socks5 прокси
/usr/sbin/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &

# Ожидание запуска Tailscale
sleep 10

# Авторизация в Tailscale, используя ENV переменную TAILSCALE_AUTH_KEY
tailscale up --authkey $TAILSCALE_AUTH_KEY --hostname=zabbix-neon

# Ожидание, чтобы убедиться, что Tailscale поднят
sleep 5

echo "Tailscale setup completed."

# Бесконечный цикл, чтобы процесс не упал в supervisor
while true; do
    sleep 86400
done
