---
title: "Подключение с любого устройства"
description: "Настройка клиента Shadowsocks на Windows, macOS, Linux, Android и iOS."
slug: "nastrojka-klienta"
layout: "guides/single"
estimated_time: 10
difficulty: "beginner"
prerequisites:
  - "Работающий сервер Shadowsocks (см. руководства по настройке VPS или Raspberry Pi)"
  - "Данные вашего сервера: адрес, пароль, метод шифрования"
---

## Данные для подключения

Перед началом соберите следующую информацию из настройки вашего сервера. Она понадобится для каждого клиента:

| Параметр | Значение |
|---|---|
| **Адрес сервера** | Ваше доменное имя (например, `proxy.example.com`) |
| **Порт сервера** | `443` |
| **Пароль** | Пароль, установленный при развёртывании сервера |
| **Метод шифрования** | `aes-256-gcm` |
| **Плагин** | `v2ray-plugin` |
| **Параметры плагина** | `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0` |

{{< alert type="info" >}}
Замените `YOUR_DOMAIN` в параметрах плагина на ваше реальное доменное имя. Все остальные значения вводите точно так, как показано.
{{< /alert >}}

---

## Настройка по платформам

Выберите вашу платформу ниже для пошаговых инструкций:

{{< tabs names="Windows,macOS,Linux,Android,iOS" >}}

{{< tab index="0" >}}
### Windows

**1. Скачайте программы**

Вам нужны два файла:
- **Shadowsocks for Windows** -- Скачайте последний релиз с [github.com/shadowsocks/shadowsocks-windows/releases](https://github.com/shadowsocks/shadowsocks-windows/releases). Выберите файл `Shadowsocks-x.x.x.zip`.
- **v2ray-plugin** -- Скачайте версию для Windows с [github.com/shadowsocks/v2ray-plugin/releases](https://github.com/shadowsocks/v2ray-plugin/releases). Выберите файл `v2ray-plugin-windows-amd64-vx.x.x.tar.gz`.

**2. Подготовьте файлы**

1. Распакуйте ZIP-архив Shadowsocks в папку (например, `C:\Shadowsocks\`)
2. Извлеките `v2ray-plugin.exe` из архива v2ray-plugin
3. Поместите `v2ray-plugin.exe` в **ту же папку**, что и `Shadowsocks.exe`

**3. Настройте клиент**

1. Запустите `Shadowsocks.exe` -- в системном трее появится новая иконка (правый нижний угол)
2. Нажмите правой кнопкой на иконку Shadowsocks в трее и выберите **Edit Servers**
3. Заполните поля:
   - **Server Addr:** `YOUR_DOMAIN`
   - **Server Port:** `443`
   - **Password:** ваш пароль
   - **Encryption:** `aes-256-gcm`
   - **Plugin Program:** `v2ray-plugin`
   - **Plugin Options:** `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
4. Нажмите **Apply**, затем **OK**

**4. Включите прокси**

Нажмите правой кнопкой на иконку Shadowsocks в трее и выберите **System Proxy** &rarr; **Global**, чтобы направить весь трафик через Shadowsocks.

Альтернативно, выберите режим **PAC**, чтобы направлять трафик только для заблокированных сайтов (использует встроенный список часто блокируемых доменов).
{{< /tab >}}

{{< tab index="1" >}}
### macOS

**1. Скачайте программы**

- **ShadowsocksX-NG** -- Скачайте с [github.com/shadowsocks/ShadowsocksX-NG/releases](https://github.com/shadowsocks/ShadowsocksX-NG/releases). Выберите файл `.dmg`.
- **v2ray-plugin** -- Скачайте версию для macOS с [github.com/shadowsocks/v2ray-plugin/releases](https://github.com/shadowsocks/v2ray-plugin/releases). Выберите файл `v2ray-plugin-darwin-amd64-vx.x.x.tar.gz` (или `arm64`, если у вас Mac с чипом M-серии).

**2. Установите v2ray-plugin**

Извлеките плагин и переместите его в системный путь:

```
tar xzf v2ray-plugin-darwin-*.tar.gz
sudo cp v2ray-plugin /usr/local/bin/
sudo chmod +x /usr/local/bin/v2ray-plugin
```

**3. Настройте клиент**

1. Откройте `ShadowsocksX-NG.dmg` и перетащите приложение в папку Applications
2. Запустите ShadowsocksX-NG -- оно появится в строке меню
3. Нажмите на иконку бумажного самолётика в строке меню и выберите **Server Preferences**
4. Нажмите кнопку **+**, чтобы добавить новый сервер
5. Заполните поля:
   - **Address:** `YOUR_DOMAIN`
   - **Port:** `443`
   - **Password:** ваш пароль
   - **Encryption:** `aes-256-gcm`
   - **Plugin:** `v2ray-plugin`
   - **Plugin Options:** `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
6. Нажмите **OK**

**4. Включите прокси**

Нажмите на иконку ShadowsocksX-NG в строке меню и выберите **Turn Shadowsocks On**. Выберите **Global Mode** для маршрутизации всего трафика или **PAC Mode** для выборочной маршрутизации.
{{< /tab >}}

{{< tab index="2" >}}
### Linux

**1. Установите shadowsocks-libev и v2ray-plugin**

На Ubuntu или Debian:

```
sudo apt update
sudo apt install -y shadowsocks-libev
```

Скачайте v2ray-plugin:

```
wget https://github.com/shadowsocks/v2ray-plugin/releases/latest/download/v2ray-plugin-linux-amd64-v1.3.2.tar.gz
tar xzf v2ray-plugin-linux-amd64-*.tar.gz
sudo mv v2ray-plugin /usr/local/bin/
sudo chmod +x /usr/local/bin/v2ray-plugin
```

**2. Создайте конфигурацию клиента**

Создайте файл конфигурации:

```
sudo nano /etc/shadowsocks-libev/client.json
```

Вставьте следующее (замените значения-заполнители):

```json
{
    "server": "YOUR_DOMAIN",
    "server_port": 443,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "YOUR_PASSWORD",
    "method": "aes-256-gcm",
    "plugin": "v2ray-plugin",
    "plugin_opts": "tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0"
}
```

**3. Запустите клиент**

Запустите локальный прокси Shadowsocks:

```
ss-local -c /etc/shadowsocks-libev/client.json
```

Для запуска в фоновом режиме как сервиса:

```
sudo systemctl start shadowsocks-libev-local@client
sudo systemctl enable shadowsocks-libev-local@client
```

**4. Настройте ваши приложения**

Локальный SOCKS5-прокси теперь доступен по адресу `127.0.0.1:1080`. Настройте ваш браузер или систему для его использования:

- **Firefox:** Настройки &rarr; Настройки сети &rarr; Ручная настройка прокси &rarr; SOCKS-хост: `127.0.0.1`, Порт: `1080`, SOCKS v5
- **Системный уровень:** Установите переменные окружения `ALL_PROXY=socks5://127.0.0.1:1080` или используйте `proxychains`
{{< /tab >}}

{{< tab index="3" >}}
### Android

**1. Установите приложения**

Установите оба приложения из Google Play Store:
- **[Shadowsocks](https://play.google.com/store/apps/details?id=com.github.shadowsocks)** -- Официальный клиент Shadowsocks
- **[v2ray Plugin](https://play.google.com/store/apps/details?id=com.github.nicecoolwind.shadowsocksr.v2ray.plugin)** -- v2ray-plugin для Android

Если Play Store недоступен в вашей стране, APK-файлы можно скачать с [github.com/shadowsocks/shadowsocks-android/releases](https://github.com/shadowsocks/shadowsocks-android/releases).

**2. Настройте клиент**

1. Откройте приложение Shadowsocks
2. Нажмите кнопку **+**, чтобы добавить новый профиль
3. Выберите **Manual Settings** и заполните:
   - **Profile Name:** любое имя (например, "Мой прокси")
   - **Server:** `YOUR_DOMAIN`
   - **Remote Port:** `443`
   - **Password:** ваш пароль
   - **Encrypt Method:** `aes-256-gcm`
   - **Plugin:** выберите `v2ray`
   - **Configure:** `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
4. Нажмите галочку для сохранения

**3. Подключитесь**

Нажмите на только что созданный профиль, затем нажмите иконку бумажного самолётика для подключения. Android попросит разрешить VPN-соединение -- это нормально; Shadowsocks использует API VPN в Android для маршрутизации трафика.
{{< /tab >}}

{{< tab index="4" >}}
### iOS

Из-за ограничений App Store от Apple бесплатных клиентов Shadowsocks с поддержкой v2ray-plugin для iOS нет. Рекомендуемые варианты:

**Вариант 1: Shadowrocket ($2.99)**

[Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) -- наиболее популярный и надёжный вариант.

1. Купите и установите Shadowrocket из App Store
2. Откройте приложение и нажмите **+**, чтобы добавить сервер
3. Выберите **Type: Shadowsocks**
4. Заполните поля:
   - **Address:** `YOUR_DOMAIN`
   - **Port:** `443`
   - **Password:** ваш пароль
   - **Algorithm:** `aes-256-gcm`
   - **Obfs:** выберите `websocket`
   - **Obfs Host:** `YOUR_DOMAIN`
   - **Obfs Path:** `/shadowsocks`
   - **Enable TLS:** ON
5. Нажмите **Done**, затем нажмите переключатель для подключения

**Вариант 2: Potatso Lite (бесплатно)**

[Potatso Lite](https://apps.apple.com/app/potatso-lite/id1239860606) -- бесплатная альтернатива, хотя она может не поддерживать все функции v2ray-plugin.

1. Установите Potatso Lite из App Store
2. Нажмите **Add** &rarr; **Manual Input**
3. Выберите **Shadowsocks** и введите данные вашего сервера
4. Для настроек плагина введите: `v2ray-plugin;tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
5. Сохраните и подключитесь

{{< alert type="info" >}}
Если Shadowrocket недоступен в App Store вашей страны, возможно, потребуется создать Apple ID в другом регионе (например, в App Store США) для его покупки.
{{< /alert >}}
{{< /tab >}}

{{< /tabs >}}

---

## Проверка соединения

После подключения на любой платформе выполните эти три проверки, чтобы убедиться, что всё работает правильно:

### 1. Проверьте ваш IP-адрес

Откройте [whatismyipaddress.com](https://whatismyipaddress.com). Вы должны увидеть **IP-адрес вашего сервера** (для VPS) или **ваш домашний IP-адрес** (для Raspberry Pi), а не IP-адрес сети, к которой вы сейчас подключены.

### 2. Тест на утечку DNS

Откройте [dnsleaktest.com](https://dnsleaktest.com) и нажмите **Extended Test**. Результаты должны показывать DNS-серверы, связанные с расположением вашего сервера Shadowsocks, а не вашего текущего провайдера. Если вы видите DNS-серверы вашего провайдера, происходит утечка DNS, и вам может потребоваться настроить клиент для проксирования DNS-запросов.

### 3. Тест скорости

Откройте [speedtest.net](https://speedtest.net) и запустите тест. Скорость должна быть в пределах 10% от вашей обычной скорости интернета. Если скорость значительно ниже:

- Попробуйте подключиться к серверу Shadowsocks, расположенному ближе к вам географически
- Если используете Raspberry Pi, убедитесь, что он подключён через Ethernet
- Проверьте, не является ли узким местом ваш VPS или домашний интернет

---

## Устранение неполадок

### Время ожидания соединения истекло

- Убедитесь, что ваш сервер работает: подключитесь по SSH и выполните `docker ps`
- Проверьте, что пароль, метод шифрования и параметры плагина точно совпадают между клиентом и сервером
- Убедитесь, что порт 443 открыт в фаерволе сервера

### Подключение есть, но нет доступа к интернету

- Проверьте подключение сервера к интернету: подключитесь по SSH и выполните `curl https://example.com`
- На Linux убедитесь, что ваше приложение настроено на использование SOCKS5-прокси `127.0.0.1:1080`
- На Windows/macOS попробуйте переключиться между режимами прокси Global и PAC

### Ошибки плагина

- Убедитесь, что v2ray-plugin установлен и доступен (в той же папке, что и Shadowsocks на Windows, или в `/usr/local/bin/` на macOS/Linux)
- Проверьте, что строка параметров плагина точно: `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
- Проверьте, что SSL-сертификат вашего домена действителен, открыв `https://YOUR_DOMAIN` в браузере

### Низкая производительность

- Выберите сервер, расположенный географически ближе к вам
- Проверьте скорость вашего сервера напрямую, запустив тест скорости на самом сервере: `curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -`
- Если используете Raspberry Pi, проверьте загрузку процессора Pi: `top`
