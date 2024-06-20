#!/bin/bash

# START_FILE="/tmp/start_results.txt"
# : > $START_FILE

# Запуск Tailscale daemon
/usr/sbin/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &

# Ожидание запуска Tailscale
sleep 10

# Авторизация в Tailscale, используя ENV переменную TAILSCALE_AUTH_KEY
tailscale up --authkey $TAILSCALE_AUTH_KEY --hostname=zabbix-neon
tailscale ip -4

# Ожидание, чтобы убедиться, что Tailscale поднят
sleep 5

echo "Tailscale setup completed."

# CLOUD_USER="elux-bors@mail.ru"
# CLOUD_PASSWORD="qfJricqHNkTspwD3pByU"
# CLOUD_URL="https://webdav.mail.ru"

# curl -u $CLOUD_USER:$CLOUD_PASSWORD -T $START_FILE "$CLOUD_URL/start_results.txt"

# Бесконечный цикл с интервалом ожидания 1 день
while true; do
    sleep 86400 # Ожидание 1 день (86400 секунд)
done
