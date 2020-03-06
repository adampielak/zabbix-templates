[![N|zabbix logo](https://avatars1.githubusercontent.com/u/4561226?s=200&v=4)](https://www.zabbix.com/)[![N|letsencrypt logo](https://avatars0.githubusercontent.com/u/9289019?s=200&v=4)](https://github.com/letsencrypt) [![N|certbot log](https://certbot.eff.org/images/Certbot-solid.svg)](https://github.com/certbot/certbot)
# Шаблон для мониторинга сертификатов Let's Encrypt созданных с помощью Certbot

> **Установка:**

 1. Скопируйте скрипт `le-certificates.sh` в `/etc/zabbix/scripts`

> каталог `/etc/zabbix/scripts` должен существовать, можно создать так:
> `mkdir -p /etc/zabbix/scripts`

 2. Скопируйте конфиг  `userparameter_le_certificates.conf`в `/etc/zabbix/zabbix_agentd.d`
 3. Создайте файл `/etc/sudoers.d/zabbix_le_certificates`> Пример содержания в файле `sudoers-zabbix`

> Для centos/rhel пример в файле `sudoers-zabbix-centos` , отличие в отключении логов sudo для zabbix
 4. Задайте владельца и группу у созданных файлов и каталогов
> `chown root:zabbix /etc/zabbix/scripts/le-certificates.sh \
&& chown root:zabbix /etc/zabbix/zabbix_agentd.d/userparameter_le_certificates.conf \
&& chown root:root /etc/sudoers.d/zabbix_le_certificates`
 5. Задайте права Unix
> `chmod 750 /etc/zabbix/scripts/le-certificates.sh \
&& chmod 640 /etc/zabbix/zabbix_agentd.d/userparameter_le_certificates.conf \
&& chmod 600 /etc/sudoers.d/zabbix_le_certificates`
 6. Импортируйте шаблон Zabbix `zabbix-4.4-template.xml`
> Данный шаблон совместим с версией Zabbix 4.4 и выше

 7.  Прикрепите шаблон к целевым хостам в Zabbix
