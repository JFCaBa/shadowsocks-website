---
title: "Conectar desde cualquier dispositivo"
description: "Configura el cliente Shadowsocks en Windows, macOS, Linux, Android e iOS."
slug: "configurar-cliente"
layout: "guides/single"
estimated_time: 10
difficulty: "beginner"
prerequisites:
  - "Un servidor Shadowsocks en funcionamiento (consulta las guías de configuración de VPS o Raspberry Pi)"
  - "Los datos de tu servidor: dirección, contraseña, método de cifrado"
---

## Tus datos de conexión

Antes de empezar, reúne la siguiente información de la configuración de tu servidor. La necesitarás para cada cliente:

| Configuración | Valor |
|---|---|
| **Dirección del servidor** | Tu nombre de dominio (por ejemplo, `proxy.example.com`) |
| **Puerto del servidor** | `443` |
| **Contraseña** | La contraseña que estableciste durante el despliegue del servidor |
| **Método de cifrado** | `aes-256-gcm` |
| **Plugin** | `v2ray-plugin` |
| **Opciones del plugin** | `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0` |

{{< alert type="info" >}}
Reemplaza `YOUR_DOMAIN` en las opciones del plugin con tu nombre de dominio real. Todos los demás valores deben introducirse exactamente como se muestran.
{{< /alert >}}

---

## Configuración por plataforma

Elige tu plataforma a continuación para instrucciones paso a paso:

{{< tabs names="Windows,macOS,Linux,Android,iOS" >}}

{{< tab index="0" >}}
### Windows

**1. Descarga el software**

Necesitas dos archivos:
- **Shadowsocks para Windows** -- Descarga la última versión desde [github.com/shadowsocks/shadowsocks-windows/releases](https://github.com/shadowsocks/shadowsocks-windows/releases). Obtén el archivo `Shadowsocks-x.x.x.zip`.
- **v2ray-plugin** -- Descarga la versión para Windows desde [github.com/shadowsocks/v2ray-plugin/releases](https://github.com/shadowsocks/v2ray-plugin/releases). Obtén el archivo `v2ray-plugin-windows-amd64-vx.x.x.tar.gz`.

**2. Prepara los archivos**

1. Extrae el ZIP de Shadowsocks en una carpeta (por ejemplo, `C:\Shadowsocks\`)
2. Extrae `v2ray-plugin.exe` del archivo v2ray-plugin
3. Coloca `v2ray-plugin.exe` en la **misma carpeta** que `Shadowsocks.exe`

**3. Configura el cliente**

1. Ejecuta `Shadowsocks.exe` -- aparecerá un nuevo icono en la bandeja del sistema (esquina inferior derecha)
2. Haz clic derecho en el icono de Shadowsocks en la bandeja y selecciona **Edit Servers**
3. Rellena los campos:
   - **Server Addr:** `YOUR_DOMAIN`
   - **Server Port:** `443`
   - **Password:** tu contraseña
   - **Encryption:** `aes-256-gcm`
   - **Plugin Program:** `v2ray-plugin`
   - **Plugin Options:** `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
4. Haz clic en **Apply** y luego en **OK**

**4. Activa el proxy**

Haz clic derecho en el icono de Shadowsocks en la bandeja y selecciona **System Proxy** &rarr; **Global** para enrutar todo el tráfico a través de Shadowsocks.

Alternativamente, elige el modo **PAC** para enrutar solo el tráfico de sitios bloqueados (usa una lista integrada de dominios comúnmente bloqueados).
{{< /tab >}}

{{< tab index="1" >}}
### macOS

**1. Descarga el software**

- **ShadowsocksX-NG** -- Descarga desde [github.com/shadowsocks/ShadowsocksX-NG/releases](https://github.com/shadowsocks/ShadowsocksX-NG/releases). Obtén el archivo `.dmg`.
- **v2ray-plugin** -- Descarga la versión para macOS desde [github.com/shadowsocks/v2ray-plugin/releases](https://github.com/shadowsocks/v2ray-plugin/releases). Obtén el archivo `v2ray-plugin-darwin-amd64-vx.x.x.tar.gz` (o `arm64` si tienes un Mac con chip M).

**2. Instala v2ray-plugin**

Extrae el plugin y muévelo a una ruta del sistema:

```
tar xzf v2ray-plugin-darwin-*.tar.gz
sudo cp v2ray-plugin /usr/local/bin/
sudo chmod +x /usr/local/bin/v2ray-plugin
```

**3. Configura el cliente**

1. Abre `ShadowsocksX-NG.dmg` y arrastra la aplicación a tu carpeta de Aplicaciones
2. Ejecuta ShadowsocksX-NG -- aparecerá en la barra de menú
3. Haz clic en el icono del avión de papel en la barra de menú y selecciona **Server Preferences**
4. Haz clic en el botón **+** para añadir un nuevo servidor
5. Rellena los campos:
   - **Address:** `YOUR_DOMAIN`
   - **Port:** `443`
   - **Password:** tu contraseña
   - **Encryption:** `aes-256-gcm`
   - **Plugin:** `v2ray-plugin`
   - **Plugin Options:** `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
6. Haz clic en **OK**

**4. Activa el proxy**

Haz clic en el icono de ShadowsocksX-NG en la barra de menú y selecciona **Turn Shadowsocks On**. Elige **Global Mode** para enrutar todo el tráfico, o **PAC Mode** para enrutamiento selectivo.
{{< /tab >}}

{{< tab index="2" >}}
### Linux

**1. Instala shadowsocks-libev y v2ray-plugin**

En Ubuntu o Debian:

```
sudo apt update
sudo apt install -y shadowsocks-libev
```

Descarga v2ray-plugin:

```
wget https://github.com/shadowsocks/v2ray-plugin/releases/latest/download/v2ray-plugin-linux-amd64-v1.3.2.tar.gz
tar xzf v2ray-plugin-linux-amd64-*.tar.gz
sudo mv v2ray-plugin /usr/local/bin/
sudo chmod +x /usr/local/bin/v2ray-plugin
```

**2. Crea la configuración del cliente**

Crea el archivo de configuración:

```
sudo nano /etc/shadowsocks-libev/client.json
```

Pega lo siguiente (reemplaza los valores de ejemplo):

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

**3. Inicia el cliente**

Ejecuta el proxy local de Shadowsocks:

```
ss-local -c /etc/shadowsocks-libev/client.json
```

Para ejecutarlo en segundo plano como servicio:

```
sudo systemctl start shadowsocks-libev-local@client
sudo systemctl enable shadowsocks-libev-local@client
```

**4. Configura tus aplicaciones**

El proxy SOCKS5 local ahora está disponible en `127.0.0.1:1080`. Configura tu navegador o sistema para usarlo:

- **Firefox:** Ajustes &rarr; Configuración de red &rarr; Proxy manual &rarr; SOCKS Host: `127.0.0.1`, Puerto: `1080`, SOCKS v5
- **Todo el sistema:** Establece las variables de entorno `ALL_PROXY=socks5://127.0.0.1:1080` o usa `proxychains`
{{< /tab >}}

{{< tab index="3" >}}
### Android

**1. Instala las aplicaciones**

Instala ambas aplicaciones desde Google Play Store:
- **[Shadowsocks](https://play.google.com/store/apps/details?id=com.github.shadowsocks)** -- El cliente oficial de Shadowsocks
- **[v2ray Plugin](https://play.google.com/store/apps/details?id=com.github.nicecoolwind.shadowsocksr.v2ray.plugin)** -- El v2ray-plugin para Android

Si Google Play Store no está disponible en tu país, puedes descargar los archivos APK desde [github.com/shadowsocks/shadowsocks-android/releases](https://github.com/shadowsocks/shadowsocks-android/releases).

**2. Configura el cliente**

1. Abre la aplicación Shadowsocks
2. Toca el botón **+** para añadir un nuevo perfil
3. Selecciona **Manual Settings** y rellena:
   - **Profile Name:** cualquier nombre que desees (por ejemplo, "Mi Proxy")
   - **Server:** `YOUR_DOMAIN`
   - **Remote Port:** `443`
   - **Password:** tu contraseña
   - **Encrypt Method:** `aes-256-gcm`
   - **Plugin:** selecciona `v2ray`
   - **Configure:** `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
4. Toca la marca de verificación para guardar

**3. Conéctate**

Toca el perfil que acabas de crear, luego toca el icono del avión de papel para conectar. Android te pedirá permitir una conexión VPN -- esto es normal; Shadowsocks usa la API de VPN de Android para enrutar el tráfico.
{{< /tab >}}

{{< tab index="4" >}}
### iOS

Debido a las restricciones de la App Store de Apple, no existen clientes gratuitos de Shadowsocks con soporte de v2ray-plugin para iOS. Las opciones recomendadas son:

**Opción 1: Shadowrocket ($2.99)**

[Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) es la opción más popular y fiable.

1. Compra e instala Shadowrocket desde la App Store
2. Abre la aplicación y toca **+** para añadir un servidor
3. Selecciona **Type: Shadowsocks**
4. Rellena los campos:
   - **Address:** `YOUR_DOMAIN`
   - **Port:** `443`
   - **Password:** tu contraseña
   - **Algorithm:** `aes-256-gcm`
   - **Obfs:** selecciona `websocket`
   - **Obfs Host:** `YOUR_DOMAIN`
   - **Obfs Path:** `/shadowsocks`
   - **Enable TLS:** ON
5. Toca **Done** y luego toca el interruptor para conectar

**Opción 2: Potatso Lite (Gratuito)**

[Potatso Lite](https://apps.apple.com/app/potatso-lite/id1239860606) es una alternativa gratuita, aunque puede que no soporte todas las funciones del v2ray-plugin.

1. Instala Potatso Lite desde la App Store
2. Toca **Add** &rarr; **Manual Input**
3. Selecciona **Shadowsocks** y rellena los datos de tu servidor
4. Para la configuración del plugin, introduce: `v2ray-plugin;tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
5. Guarda y conecta

{{< alert type="info" >}}
Si Shadowrocket no está disponible en la App Store de tu país, es posible que necesites crear un Apple ID en una región diferente (como la App Store de EE. UU.) para comprarlo.
{{< /alert >}}
{{< /tab >}}

{{< /tabs >}}

---

## Verifica tu conexión

Después de conectarte en cualquier plataforma, realiza estas tres comprobaciones para asegurarte de que todo funciona correctamente:

### 1. Comprueba tu dirección IP

Visita [whatismyipaddress.com](https://whatismyipaddress.com). Deberías ver la **dirección IP de tu servidor** (para un VPS) o tu **dirección IP doméstica** (para una Raspberry Pi), no la dirección IP de la red a la que estás conectado actualmente.

### 2. Test de fugas DNS

Visita [dnsleaktest.com](https://dnsleaktest.com) y haz clic en **Extended Test**. Los resultados deberían mostrar servidores DNS asociados con la ubicación de tu servidor Shadowsocks, no de tu ISP actual. Si ves los servidores DNS de tu ISP, tu DNS está filtrándose y puede que necesites configurar tu cliente para que también enrute las consultas DNS a través del proxy.

### 3. Test de velocidad

Visita [speedtest.net](https://speedtest.net) y ejecuta un test. Deberías ver velocidades dentro del 10% aproximado de tu velocidad normal de internet. Si la velocidad es significativamente más lenta:

- Intenta conectarte a un servidor Shadowsocks más cercano a tu ubicación física
- Si usas una Raspberry Pi, asegúrate de que esté conectada por Ethernet
- Comprueba que tu VPS o conexión de internet doméstica no sea el cuello de botella

---

## Resolución de problemas

### La conexión se agota

- Verifica que tu servidor esté en ejecución: conéctate por SSH al servidor y ejecuta `docker ps`
- Comprueba que la contraseña, el método de cifrado y las opciones del plugin coincidan exactamente entre el cliente y el servidor
- Asegúrate de que el puerto 443 esté abierto en el cortafuegos del servidor

### Conectado pero sin acceso a internet

- Comprueba la conectividad de internet de tu servidor: conéctate por SSH y ejecuta `curl https://example.com`
- En Linux, asegúrate de que tu aplicación esté configurada para usar el proxy SOCKS5 en `127.0.0.1:1080`
- En Windows/macOS, intenta cambiar entre los modos de proxy Global y PAC

### Errores del plugin

- Asegúrate de que v2ray-plugin esté instalado y accesible (en la misma carpeta que Shadowsocks en Windows, o en `/usr/local/bin/` en macOS/Linux)
- Verifica que la cadena de opciones del plugin sea exactamente: `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
- Comprueba que el certificado SSL de tu dominio sea válido visitando `https://YOUR_DOMAIN` en un navegador

### Rendimiento lento

- Elige una ubicación de servidor geográficamente más cercana a ti
- Prueba la velocidad bruta de tu servidor ejecutando un test de velocidad directamente en el servidor: `curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -`
- Si usas una Raspberry Pi, comprueba el uso de CPU de la Pi: `top`
