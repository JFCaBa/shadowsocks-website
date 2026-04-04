---
title: "Развёртывание Shadowsocks на Raspberry Pi"
description: "Разместите собственный зашифрованный прокси дома с помощью Raspberry Pi — без ежемесячных затрат."
layout: "guides/single"
estimated_time: 30
difficulty: "beginner"
mermaid: true
prerequisites:
  - "Raspberry Pi 3B+ или новее (рекомендуется Pi 4)"
  - "Карта microSD (16 ГБ+)"
  - "Кабель Ethernet или подключение по WiFi"
  - "Доменное имя"
  - "Доступ к панели управления роутера"
---

## Требования к оборудованию

Прежде чем начать, убедитесь, что у вас есть следующее:

| Компонент | Минимум | Рекомендуется |
|---|---|---|
| **Raspberry Pi** | Pi 3B+ | Pi 4 (2 ГБ+ ОЗУ) |
| **Хранилище** | microSD 16 ГБ | microSD 32 ГБ (Class 10 / A2) |
| **Блок питания** | 5V 2.5A (Pi 3) | 5V 3A USB-C (Pi 4) |
| **Сеть** | WiFi | Ethernet (более стабильно) |
| **Корпус** | Необязательно | Рекомендуется (с пассивным охлаждением) |

Любой Raspberry Pi начиная с 3B+ обладает достаточной мощностью для комфортной работы Shadowsocks. Pi выполняет шифрование аппаратно благодаря расширениям AES в ARM-процессоре, поэтому даже самая бюджетная модель может полностью использовать большинство домашних интернет-соединений.

---

## Как это работает

Когда вы размещаете Shadowsocks на Raspberry Pi дома, трафик проходит через ваше домашнее интернет-соединение. Вот архитектура:

{{< mermaid >}}
graph TD
    A["External Device"] -->|"HTTPS :443"| B["Router"]
    B -->|"Port Forward"| C["Raspberry Pi"]
    C --> D["Nginx + Docker"]
    D --> E["Shadowsocks"]
    E -->|"Normal Traffic"| F["ISP → Internet"]
    style A fill:#1e293b,stroke:#3b82f6,color:#e2e8f0
    style B fill:#1e293b,stroke:#f59e0b,color:#e2e8f0
    style C fill:#1e293b,stroke:#10b981,color:#e2e8f0
    style D fill:#1e293b,stroke:#8b5cf6,color:#e2e8f0
    style E fill:#1e293b,stroke:#ec4899,color:#e2e8f0
    style F fill:#1e293b,stroke:#6366f1,color:#e2e8f0
{{< /mermaid >}}

1. Ваше устройство подключается к вашему домену через HTTPS (порт 443)
2. Ваш роутер перенаправляет порт 443 на локальный IP-адрес Raspberry Pi
3. Nginx на Pi обрабатывает TLS и перенаправляет WebSocket-трафик в контейнер Shadowsocks
4. Shadowsocks расшифровывает ваш запрос и отправляет его в интернет через вашего домашнего провайдера

Ключевое преимущество: **нулевые ежемесячные затраты**. После настройки Pi работает круглосуточно, потребляя около 3-5 ватт электроэнергии (примерно $1-2 в год). Единственное требование -- ваше домашнее интернет-соединение должно оставаться активным.

---

## Шаг 1: Запись Raspberry Pi OS

1. Скачайте и установите **[Raspberry Pi Imager](https://www.raspberrypi.com/software/)** на ваш компьютер (доступен для Windows, macOS и Linux)
2. Вставьте карту microSD в компьютер
3. Откройте Raspberry Pi Imager и настройте:
   - **Operating System:** Raspberry Pi OS Lite (64-bit) -- версия "Lite" не имеет графической среды и использует меньше ресурсов
   - **Storage:** Выберите вашу карту microSD
4. Нажмите **значок шестерёнки** (или Ctrl+Shift+X), чтобы открыть дополнительные настройки:
   - **Enable SSH** и установите пароль (или добавьте ваш публичный SSH-ключ)
   - **Set hostname** -- задайте запоминающееся имя (например, `shadowsocks-pi`)
   - **Configure WiFi**, если вы не используете Ethernet
5. Нажмите **Write** и дождитесь завершения процесса
6. Вставьте карту microSD в Raspberry Pi и включите питание

{{< alert type="tip" >}}
**По возможности используйте Ethernet.** Проводное соединение более стабильно и быстрее, чем WiFi, что важно для сервера, работающего круглосуточно. Если необходимо использовать WiFi, убедитесь, что Pi имеет сильный сигнал.
{{< /alert >}}

---

## Шаг 2: Подключение по SSH

Подождите около 60 секунд для загрузки Pi, затем подключитесь с вашего компьютера:

{{< code lang="bash" >}}
ssh pi@shadowsocks-pi.local
{{< /code >}}

Если разрешение имени `.local` не работает в вашей сети, найдите IP-адрес Pi на странице администрирования роутера (обычно `192.168.1.1` или `192.168.0.1`) и подключитесь напрямую по IP:

{{< code lang="bash" >}}
ssh pi@192.168.1.XXX
{{< /code >}}

После подключения обновите систему:

{{< code lang="bash" >}}
sudo apt update && sudo apt upgrade -y
{{< /code >}}

---

## Шаг 3: Установка статического IP-адреса

Вашему Raspberry Pi нужен фиксированный IP-адрес в локальной сети, чтобы правила переадресации портов не сбивались при перезагрузке Pi.

Отредактируйте конфигурацию DHCP-клиента:

{{< code lang="bash" >}}
sudo nano /etc/dhcpcd.conf
{{< /code >}}

Добавьте следующее в конец файла (скорректируйте значения под вашу сеть):

{{< code lang="bash" >}}
interface eth0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=1.1.1.1 8.8.8.8
{{< /code >}}

{{< alert type="info" >}}
Если вы используете WiFi вместо Ethernet, измените `eth0` на `wlan0`. Значение `routers` должно соответствовать IP-адресу вашего роутера (обычно `192.168.1.1` или `192.168.0.1`). Выберите `ip_address` за пределами DHCP-диапазона вашего роутера, чтобы избежать конфликтов.
{{< /alert >}}

Перезагрузите для применения изменений:

{{< code lang="bash" >}}
sudo reboot
{{< /code >}}

Переподключитесь по SSH, используя новый статический IP:

{{< code lang="bash" >}}
ssh pi@192.168.1.100
{{< /code >}}

---

## Шаг 4: Настройка переадресации портов

Вашему роутеру необходимо перенаправлять входящий трафик на портах 80 и 443 на Raspberry Pi. Это позволяет внешним подключениям достигать Pi через ваш домашний IP-адрес.

1. Войдите в панель администрирования роутера (обычно `http://192.168.1.1`)
2. Найдите раздел **Port Forwarding** (иногда называется "Virtual Servers" или "NAT Forwarding")
3. Создайте два правила переадресации:

| Сервис | Внешний порт | Внутренний IP | Внутренний порт | Протокол |
|---|---|---|---|---|
| HTTP | 80 | 192.168.1.100 | 80 | TCP |
| HTTPS | 443 | 192.168.1.100 | 443 | TCP |

4. Сохраните настройки

{{< alert type="warning" >}}
Порт 80 нужен только временно для проверки сертификата Let's Encrypt. После получения SSL-сертификата вы можете удалить правило переадресации порта 80, хотя его сохранение позволяет автоматическое обновление сертификата.
{{< /alert >}}

---

## Шаг 5: Настройка динамического DNS

Большинство домашних интернет-соединений имеют динамический IP-адрес, который периодически меняется. Вам нужен способ поддерживать привязку домена к текущему домашнему IP. Мы будем использовать **ddclient** с Cloudflare DNS.

Установите ddclient:

{{< code lang="bash" >}}
sudo apt install -y ddclient
{{< /code >}}

Во время установки появится мастер настройки -- вы можете пропустить его со значениями по умолчанию. Мы настроим всё вручную.

Отредактируйте конфигурацию ddclient:

{{< code lang="bash" >}}
sudo nano /etc/ddclient.conf
{{< /code >}}

Замените содержимое на следующее (подставьте ваши реальные значения):

{{< code lang="bash" >}}
protocol=cloudflare
use=web
web=https://api.ipify.org
ssl=yes
zone=YOUR_DOMAIN.com
login=your-cloudflare-email@example.com
password=YOUR_CLOUDFLARE_API_TOKEN
YOUR_DOMAIN.com
{{< /code >}}

{{< alert type="info" >}}
Чтобы создать API-токен Cloudflare: войдите в Cloudflare, перейдите в **My Profile** &rarr; **API Tokens** &rarr; **Create Token**. Используйте шаблон **Edit zone DNS** и ограничьте его вашим доменом.
{{< /alert >}}

Перезапустите ddclient и включите его автозагрузку:

{{< code lang="bash" >}}
sudo systemctl restart ddclient
sudo systemctl enable ddclient
{{< /code >}}

Проверьте, что он работает:

{{< code lang="bash" >}}
sudo ddclient -query
{{< /code >}}

Эта команда должна показать ваш текущий публичный IP-адрес. Демон ddclient по умолчанию проверяет изменения IP каждые 5 минут и автоматически обновляет DNS-запись.

---

## Шаг 6: Установка Docker

Установите Docker на Raspberry Pi:

{{< code lang="bash" >}}
curl -fsSL https://get.docker.com | sh
{{< /code >}}

Добавьте пользователя `pi` в группу Docker, чтобы не использовать `sudo` для команд Docker:

{{< code lang="bash" >}}
sudo usermod -aG docker pi
{{< /code >}}

Выйдите и войдите снова, чтобы изменение группы вступило в силу:

{{< code lang="bash" >}}
exit
ssh pi@192.168.1.100
{{< /code >}}

Проверьте, что Docker работает:

{{< code lang="bash" >}}
docker --version
{{< /code >}}

---

## Шаг 7: Развёртывание контейнера Shadowsocks

Разверните сервер Shadowsocks с поддержкой v2ray-plugin:

{{< code lang="bash" >}}
docker run -d \
  --name shadowsocks \
  --restart always \
  -p 127.0.0.1:8389:8389 \
  -e PASSWORD=YOUR_STRONG_PASSWORD \
  -e METHOD=aes-256-gcm \
  jfca68/shadowsocks-server:latest
{{< /code >}}

{{< alert type="danger" >}}
**Смените пароль!** Замените `YOUR_STRONG_PASSWORD` на надёжный уникальный пароль длиной не менее 16 символов. Этот пароль шифрует весь ваш трафик.
{{< /alert >}}

Docker-образ поддерживает несколько архитектур и автоматически выбирает правильную сборку ARM64 для вашего Raspberry Pi. Специальная настройка не требуется.

Проверьте, что контейнер запущен:

{{< code lang="bash" >}}
docker ps
{{< /code >}}

Вы должны увидеть контейнер с именем `shadowsocks` и статусом `Up`.

---

## Шаг 8: Установка и настройка Nginx

Установите Nginx:

{{< code lang="bash" >}}
sudo apt install -y nginx
{{< /code >}}

Создайте конфигурацию сайта:

{{< code lang="bash" >}}
sudo nano /etc/nginx/sites-available/YOUR_DOMAIN
{{< /code >}}

Вставьте следующую конфигурацию (замените `YOUR_DOMAIN` на ваш реальный домен):

{{< code lang="nginx" >}}
server {
    listen 80;
    server_name YOUR_DOMAIN;

    location /shadowsocks {
        proxy_pass http://127.0.0.1:8389;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location / {
        return 200 'Welcome to my website';
        add_header Content-Type text/plain;
    }
}
{{< /code >}}

Активируйте сайт и перезапустите Nginx:

{{< code lang="bash" >}}
sudo ln -s /etc/nginx/sites-available/YOUR_DOMAIN /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
{{< /code >}}

---

## Шаг 9: Получение SSL-сертификата

Установите Certbot и получите SSL-сертификат:

{{< code lang="bash" >}}
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d YOUR_DOMAIN
{{< /code >}}

Когда будет предложено:
- Введите ваш email-адрес для уведомлений об обновлении
- Примите условия использования
- Выберите **Yes** для перенаправления HTTP на HTTPS

Certbot автоматически настроит Nginx для HTTPS и установит автоматическое обновление сертификата.

{{< alert type="tip" >}}
Убедитесь, что DNS вашего домена указывает на ваш домашний IP и что порт 80 перенаправлен на Pi, прежде чем запускать Certbot. Процесс проверки требует входящих HTTP-соединений.
{{< /alert >}}

---

## Шаг 10: Проверка настройки

### Тестирование с внешней сети

{{< alert type="warning" >}}
**Ограничение NAT loopback:** Большинство домашних роутеров не поддерживают NAT loopback (также называемый NAT hairpinning). Это означает, что вы **не можете** протестировать подключение Shadowsocks изнутри вашей домашней сети. Вы должны тестировать с внешней сети -- например, используя мобильную передачу данных на телефоне или попросив кого-то из другой сети попробовать.
{{< /alert >}}

1. Отключите телефон от WiFi и используйте мобильные данные
2. Откройте `https://YOUR_DOMAIN` в браузере -- вы должны увидеть действительный SSL-сертификат и текст "Welcome to my website"
3. Настройте клиент Shadowsocks на телефоне со следующими параметрами:

| Параметр | Значение |
|---|---|
| **Сервер** | `YOUR_DOMAIN` |
| **Порт сервера** | `443` |
| **Пароль** | Пароль из Шага 7 |
| **Шифрование** | `aes-256-gcm` |
| **Плагин** | `v2ray-plugin` |
| **Параметры плагина** | `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0` |

Подробные инструкции по настройке клиента смотрите в нашем руководстве [Подключение с любого устройства](/ru/guides/nastrojka-klienta/).

---

## Устранение неполадок

### Docker-контейнер не запущен

{{< code lang="bash" >}}
docker ps -a
docker logs shadowsocks
{{< /code >}}

Проверьте логи на наличие сообщений об ошибках. Распространённые проблемы включают некорректные переменные окружения или конфликты портов.

### Не удаётся подключиться к Pi извне

1. Убедитесь, что переадресация портов настроена правильно в роутере
2. Проверьте, что ваш публичный IP совпадает с тем, что сообщает ddclient: `curl https://api.ipify.org`
3. Проверьте, что Nginx слушает: `sudo ss -tlnp | grep 443`
4. Проверьте фаервол (если включён): `sudo ufw status`

### SSL-сертификат не получается

- Убедитесь, что ваш домен указывает на домашний IP: `nslookup YOUR_DOMAIN`
- Убедитесь, что порт 80 перенаправлен и Nginx запущен
- Попробуйте снова: `sudo certbot --nginx -d YOUR_DOMAIN`

### Низкая скорость

- Используйте Ethernet вместо WiFi
- Проверьте скорость загрузки вашего домашнего интернета -- это узкое место для домашнего прокси
- Убедитесь, что на Pi не запущены другие ресурсоёмкие сервисы

### Соединение работает, но часто обрывается

- Проверьте температуру Pi: `vcgencmd measure_temp` (должна быть ниже 80°C)
- Проверьте доступную память: `free -m`
- Просмотрите логи Nginx: `sudo tail -f /var/log/nginx/error.log`

---

## Что дальше?

- **[Подключите все свои устройства](/ru/guides/nastrojka-klienta/)** -- Настройте клиенты на Windows, macOS, Linux, Android и iOS
- **[Почему Shadowsocks?](/ru/pochemu-shadowsocks/)** -- Узнайте больше о технологии и её устойчивости к цензуре
- Рассмотрите настройку **автоматических обновлений**, чтобы ОС вашего Pi обновлялась автоматически:

{{< code lang="bash" >}}
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
{{< /code >}}
