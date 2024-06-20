# Zabbix-7.0-Nginx-Neon-Docker-container
## Докер контейнер в который входит всё необходимое. Предназначен для разворачивания на Render или ином хостинге. Всё выполнено в едином контейнере для обеспечения возможности бесплатного деплоя на [Render](https://render.com/). В контейнер входит Zabbix, Tailscale (VPN), Nginx, PHP8.2.

# Создайте новый сервис используя второй Branch репозитория в том случае если: у вас имеется готовая база данных для Zabbix-сервера. Во втором Branch вырезан импорт схемы БД на Neon, поскольку БД уже готова и её можно спокойно подключать. Данные сохраняются.

## Прежде, чем приступить:

1. Зарегистрируйтесь на [Neon](https://neon.tech/).
2. Создайте базу данных zabbix с пользователем zabbix.
3. Скопируйте пароль пользователя zabbix и ссылку на базу данных (ссылка вида: ep-patient-pine-a8i3xzku.eu-central-1.aws.neon.tech, остальные части не копируйте).
4. Зарегистрируйтесь на [Tailscale](https://tailscale.com/).
5. Создайте ключ авторизации и скопируйте его (ключ выдаётся на 90 дней, но после подключения узла можно отключить ему автоматический выход по истечении действия ключа).

## Основная инструкция:

1. Если планируете разворачивать на Render или ином хостинге, то пропускайте этот шаг. Если планируете разворачивать на своем сервере, то:
   ```bash
   git clone https://github.com/Elux414/Zabbix-7.0-Nginx-Neon-Docker-container
   ```
2. Выберите "New", далее "Web Service" (для Render).
3. Прокрутите страницу вниз, найдите строку "Environment Variables".
4. Указывайте следующие переменные - NEON_URL=<ссылка на БД Neon>, DB_HOST=<ссылка на БД Neon>, DB_PASSWORD=<пароль для пользователя zabbix>, AUTH_KEY=<ключ авторизации Tailscale>.
5. Сделайте деплой на Render или ином хостинге, те кто разворачивают на своем сервере:
   ```bash
   docker build --build-arg NEON_URL=<ссылка на БД Neon> --build-arg DB_HOST=<ссылка на БД Neon> --build-arg DB_PASSWORD=<пароль для пользователя zabbix> --build-arg AUTH_KEY=<ключ авторизации Tailscale> -t zb-neon .
   ```
   #### Когда начнётся процесс импорта схемы БД на Neon, то придётся ждать 2-4 часа. Такая же ситуация будет, если вы решите попробовать импортировать самостоятельно схему БД на Neon, не в рамках сборки контейнера.
6. Для тех кто на своём сервере:
   ```bash
   docker run --name=zb-neon -itd zb-neon
   ```
   Если контейнер не подключился к Tailscale, то:
   ```bash
   docker run -e TAILSCALE_AUTH_KEY=<ключ авторизации Tailscale> --name=zb-neon -itd zb-neon
   ```

### Всё должно работать по ссылке, которую преоставляет Render или иной хостинг, либо же переходите по IP-адресу своего сервера.

## После деплоя:

1. Подключите своё устройство/устройства к своей сети Tailscale (можно по тому же самому ключу авторизации) или же перейти по ссылке, которая будет выведена после выполнения команды:
```bash
tailscale up
```
2. В интерфейсе [Tailscale](https://login.tailscale.com/admin/machines] посмотрите IP-адрес Zabbix-сервера, скопируйте его.
3. Редактируйте конфиг Zabbix-агента на своём устройстве, необходимо прописать IP-адрес в директиве "Server" и "ServerActive", а также задать имя хоста в директиве "Hostname".
4. В интерфейсе Zabbix-сервера добавьте хоста с именем, которое указали в конфиге агента. Интерфейс НЕ ЗАДАЁТЕ. Шаблон проверки выбираете любой нужный, главное чтобы в названии присуствовало "Active".

## Готово, Active значит то, что агент будет самостоятельно отправлять данные, поскольку сервер сам не видит других участников VPN (ограничения привилегий мешают), однако если у вас есть белый IP, то можно настроить проброс портов и может тогда вам даже не нужен будет Tailscale. Если у вас несколько хостов, то можно настроить Zabbix-прокси у себя и уже с прокси отправлять данные на сервер.

## Итог:

У вас имеется Zabbix-сервер на хостинге или вашем сервере. База данных также облачная, но с ограничением на память (500 мегабайт максимальный вес), но если настроите период хранения данных в Zabbix-сервере, то место можно будет экономить. VPN посредством Tailscale.

## P.S: Теоретически можно указать вместо IP-адреса ссылку на Zabbix-сервер в конфиге агента, которую предоставляет Render без http/https, просто имя, но тогда данные не будут шифроваться, тут уже решать вам как удобнее будет.
## P.S2: Вам нужно обеспечить то, чтобы контейнер на Render не останавливался автоматически при отсутствии посетителей через 15 минут. Можно создать скрипт, который будет делать HTTP запрос, далее в Cron создать задачу на исполнение скрипта каждые 14 минут. Для реализации скрипта можно использовать wget или curl, итог будет один и тот же.

# Если сервис остановится, то ip-адрес в Tailscale поменяется, имейте это ввиду. 
