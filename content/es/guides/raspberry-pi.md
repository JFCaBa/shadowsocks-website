---
title: "Desplegar Shadowsocks en una Raspberry Pi"
description: "Autoaloja tu propio proxy cifrado en casa con una Raspberry Pi — sin coste mensual."
slug: "raspberry-pi"
layout: "guides/single"
estimated_time: 30
difficulty: "beginner"
mermaid: true
prerequisites:
  - "Una Raspberry Pi 3B+ o más reciente (se recomienda Pi 4)"
  - "Una tarjeta microSD (16 GB+)"
  - "Cable Ethernet o conexión WiFi"
  - "Un nombre de dominio"
  - "Acceso al panel de administración de tu router"
---

## Requisitos de hardware

Antes de empezar, asegúrate de tener lo siguiente:

| Componente | Mínimo | Recomendado |
|---|---|---|
| **Raspberry Pi** | Pi 3B+ | Pi 4 (2 GB+ RAM) |
| **Almacenamiento** | microSD de 16 GB | microSD de 32 GB (Clase 10 / A2) |
| **Fuente de alimentación** | 5V 2.5A (Pi 3) | 5V 3A USB-C (Pi 4) |
| **Red** | WiFi | Ethernet (más estable) |
| **Carcasa** | Opcional | Recomendada (con refrigeración pasiva) |

Cualquier Raspberry Pi a partir del modelo 3B+ tiene suficiente potencia para ejecutar Shadowsocks cómodamente. La Pi maneja el cifrado por hardware a través de las extensiones AES del procesador ARM, por lo que incluso el modelo más barato puede saturar la mayoría de las conexiones de internet domésticas.

---

## Cómo funciona

Cuando alojas Shadowsocks en una Raspberry Pi en casa, el tráfico fluye a través de tu conexión de internet doméstica. Esta es la arquitectura:

{{< mermaid >}}
graph LR
    A["Dispositivo Externo"] -->|"HTTPS :443"| B["Router"]
    B -->|"Port Forward"| C["Raspberry Pi"]
    C --> D["Nginx + Docker"]
    D --> E["Shadowsocks"]
    E -->|"Tráfico Normal"| F["ISP → Internet"]
    style A fill:#1e293b,stroke:#3b82f6,color:#e2e8f0
    style B fill:#1e293b,stroke:#f59e0b,color:#e2e8f0
    style C fill:#1e293b,stroke:#10b981,color:#e2e8f0
    style D fill:#1e293b,stroke:#8b5cf6,color:#e2e8f0
    style E fill:#1e293b,stroke:#ec4899,color:#e2e8f0
    style F fill:#1e293b,stroke:#6366f1,color:#e2e8f0
{{< /mermaid >}}

1. Tu dispositivo se conecta a tu dominio por HTTPS (puerto 443)
2. Tu router reenvía el puerto 443 a la IP local de la Raspberry Pi
3. Nginx en la Pi gestiona TLS y reenvía el tráfico WebSocket al contenedor Shadowsocks
4. Shadowsocks descifra tu solicitud y la envía a internet a través de tu ISP doméstico

La ventaja clave: **cero coste mensual**. Una vez configurada la Pi, funciona las 24 horas del día, los 7 días de la semana, consumiendo aproximadamente 3-5 vatios de electricidad (unos $1-2 al año). El único requisito es que tu conexión a internet doméstica se mantenga activa.

---

## Paso 1: Instala Raspberry Pi OS

1. Descarga e instala el **[Raspberry Pi Imager](https://www.raspberrypi.com/software/)** en tu ordenador (disponible para Windows, macOS y Linux)
2. Inserta tu tarjeta microSD en tu ordenador
3. Abre Raspberry Pi Imager y configura:
   - **Sistema operativo:** Raspberry Pi OS Lite (64-bit) -- la versión "Lite" no tiene entorno de escritorio y usa menos recursos
   - **Almacenamiento:** Selecciona tu tarjeta microSD
4. Haz clic en el **icono del engranaje** (o presiona Ctrl+Shift+X) para abrir la configuración avanzada:
   - **Activa SSH** y establece una contraseña (o añade tu clave SSH pública)
   - **Establece el hostname** con algo memorable (por ejemplo, `shadowsocks-pi`)
   - **Configura WiFi** si no vas a usar Ethernet
5. Haz clic en **Write** y espera a que el proceso se complete
6. Inserta la tarjeta microSD en tu Raspberry Pi y enciéndela

{{< alert type="tip" >}}
**Usa Ethernet si es posible.** Una conexión por cable es más estable y rápida que WiFi, lo cual importa para un servidor que funciona las 24 horas. Si debes usar WiFi, asegúrate de que la Pi tenga buena señal.
{{< /alert >}}

---

## Paso 2: Conéctate por SSH

Espera unos 60 segundos a que la Pi arranque, luego conéctate desde tu ordenador:

{{< code lang="bash" >}}
ssh pi@shadowsocks-pi.local
{{< /code >}}

Si la resolución del hostname `.local` no funciona en tu red, encuentra la dirección IP de la Pi desde la página de administración de tu router (normalmente en `192.168.1.1` o `192.168.0.1`) y conéctate usando la IP directamente:

{{< code lang="bash" >}}
ssh pi@192.168.1.XXX
{{< /code >}}

Una vez conectado, actualiza el sistema:

{{< code lang="bash" >}}
sudo apt update && sudo apt upgrade -y
{{< /code >}}

---

## Paso 3: Establece una IP estática

Tu Raspberry Pi necesita una dirección IP fija en tu red local para que las reglas de reenvío de puertos no se rompan cuando la Pi se reinicie.

Edita la configuración del cliente DHCP:

{{< code lang="bash" >}}
sudo nano /etc/dhcpcd.conf
{{< /code >}}

Añade lo siguiente al final del archivo (ajusta los valores para tu red):

{{< code lang="bash" >}}
interface eth0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=1.1.1.1 8.8.8.8
{{< /code >}}

{{< alert type="info" >}}
Si estás usando WiFi en lugar de Ethernet, cambia `eth0` por `wlan0`. El valor de `routers` debería ser la dirección IP de tu router (normalmente `192.168.1.1` o `192.168.0.1`). Elige una `ip_address` que esté fuera del rango DHCP de tu router para evitar conflictos.
{{< /alert >}}

Reinicia para aplicar los cambios:

{{< code lang="bash" >}}
sudo reboot
{{< /code >}}

Reconéctate por SSH usando la nueva IP estática:

{{< code lang="bash" >}}
ssh pi@192.168.1.100
{{< /code >}}

---

## Paso 4: Configura el reenvío de puertos

Tu router necesita reenviar el tráfico entrante en los puertos 80 y 443 a tu Raspberry Pi. Esto permite que las conexiones externas lleguen a la Pi a través de tu dirección IP doméstica.

1. Inicia sesión en el panel de administración de tu router (normalmente en `http://192.168.1.1`)
2. Busca la sección de **Port Forwarding** (a veces llamada "Virtual Servers" o "NAT Forwarding")
3. Crea dos reglas de reenvío:

| Servicio | Puerto externo | IP interna | Puerto interno | Protocolo |
|---|---|---|---|---|
| HTTP | 80 | 192.168.1.100 | 80 | TCP |
| HTTPS | 443 | 192.168.1.100 | 443 | TCP |

4. Guarda la configuración

{{< alert type="warning" >}}
El puerto 80 solo se necesita temporalmente para la validación del certificado de Let's Encrypt. Después de obtener tu certificado SSL, puedes eliminar la regla de reenvío del puerto 80 si lo prefieres, aunque mantenerla permite la renovación automática del certificado.
{{< /alert >}}

---

## Paso 5: Configura DNS dinámico

La mayoría de las conexiones de internet domésticas tienen una dirección IP dinámica que cambia periódicamente. Necesitas una forma de mantener tu dominio apuntando a tu IP doméstica actual. Usaremos **ddclient** con Cloudflare DNS.

Instala ddclient:

{{< code lang="bash" >}}
sudo apt install -y ddclient
{{< /code >}}

Durante la instalación, aparecerá el asistente de configuración -- puedes saltarlo con los valores predeterminados. Lo configuraremos manualmente.

Edita la configuración de ddclient:

{{< code lang="bash" >}}
sudo nano /etc/ddclient.conf
{{< /code >}}

Reemplaza el contenido con (sustituye tus valores reales):

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
Para crear un token de API de Cloudflare: inicia sesión en Cloudflare, ve a **My Profile** &rarr; **API Tokens** &rarr; **Create Token**. Usa la plantilla **Edit zone DNS** y restrígelo a tu dominio.
{{< /alert >}}

Reinicia ddclient y actívalo en el arranque:

{{< code lang="bash" >}}
sudo systemctl restart ddclient
sudo systemctl enable ddclient
{{< /code >}}

Verifica que está funcionando:

{{< code lang="bash" >}}
sudo ddclient -query
{{< /code >}}

Esto debería mostrar tu dirección IP pública actual. El demonio ddclient comprobará los cambios de IP cada 5 minutos por defecto y actualizará tu registro DNS automáticamente.

---

## Paso 6: Instala Docker

Instala Docker en la Raspberry Pi:

{{< code lang="bash" >}}
curl -fsSL https://get.docker.com | sh
{{< /code >}}

Añade el usuario `pi` al grupo Docker para no necesitar `sudo` en los comandos Docker:

{{< code lang="bash" >}}
sudo usermod -aG docker pi
{{< /code >}}

Cierra sesión y vuelve a iniciarla para que el cambio de grupo surta efecto:

{{< code lang="bash" >}}
exit
ssh pi@192.168.1.100
{{< /code >}}

Verifica que Docker esté en ejecución:

{{< code lang="bash" >}}
docker --version
{{< /code >}}

---

## Paso 7: Despliega el contenedor Shadowsocks

Despliega el servidor Shadowsocks con soporte de v2ray-plugin:

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
**¡Cambia la contraseña!** Reemplaza `YOUR_STRONG_PASSWORD` con una contraseña fuerte y única de al menos 16 caracteres. Esta contraseña cifra todo tu tráfico.
{{< /alert >}}

La imagen Docker es multiarquitectura y selecciona automáticamente la compilación ARM64 correcta para tu Raspberry Pi. No se necesita configuración especial.

Verifica que el contenedor esté en ejecución:

{{< code lang="bash" >}}
docker ps
{{< /code >}}

Deberías ver un contenedor llamado `shadowsocks` con estado `Up`.

---

## Paso 8: Instala y configura Nginx

Instala Nginx:

{{< code lang="bash" >}}
sudo apt install -y nginx
{{< /code >}}

Crea la configuración del sitio:

{{< code lang="bash" >}}
sudo nano /etc/nginx/sites-available/YOUR_DOMAIN
{{< /code >}}

Pega la siguiente configuración (reemplaza `YOUR_DOMAIN` con tu dominio real):

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

Activa el sitio y reinicia Nginx:

{{< code lang="bash" >}}
sudo ln -s /etc/nginx/sites-available/YOUR_DOMAIN /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
{{< /code >}}

---

## Paso 9: Obtén un certificado SSL

Instala Certbot y obtén un certificado SSL:

{{< code lang="bash" >}}
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d YOUR_DOMAIN
{{< /code >}}

Cuando se te solicite:
- Introduce tu dirección de correo electrónico para notificaciones de renovación
- Acepta los términos de servicio
- Selecciona **Sí** para redirigir HTTP a HTTPS

Certbot configurará automáticamente Nginx para HTTPS y establecerá la renovación automática del certificado.

{{< alert type="tip" >}}
Asegúrate de que el DNS de tu dominio apunte a tu IP doméstica y de que el puerto 80 esté reenviado a la Pi antes de ejecutar Certbot. El proceso de verificación requiere conexiones HTTP entrantes.
{{< /alert >}}

---

## Paso 10: Prueba tu configuración

### Prueba desde una red externa

{{< alert type="warning" >}}
**Limitación del NAT loopback:** La mayoría de los routers domésticos no soportan NAT loopback (también llamado NAT hairpinning). Esto significa que **no puedes** probar tu conexión Shadowsocks desde dentro de tu red doméstica. Debes probar desde una red externa -- por ejemplo, usando la conexión de datos móviles de tu teléfono, o pidiendo a alguien en otra red que lo intente.
{{< /alert >}}

1. Desconecta tu teléfono del WiFi y usa datos móviles
2. Visita `https://YOUR_DOMAIN` en un navegador -- deberías ver un certificado SSL válido y el texto "Welcome to my website"
3. Configura el cliente Shadowsocks en tu teléfono con estos ajustes:

| Configuración | Valor |
|---|---|
| **Servidor** | `YOUR_DOMAIN` |
| **Puerto del servidor** | `443` |
| **Contraseña** | La contraseña del Paso 7 |
| **Cifrado** | `aes-256-gcm` |
| **Plugin** | `v2ray-plugin` |
| **Opciones del plugin** | `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0` |

Para instrucciones detalladas de configuración del cliente, consulta nuestra guía [Conectar desde cualquier dispositivo](/es/guides/configurar-cliente/).

---

## Resolución de problemas

### El contenedor Docker no está en ejecución

{{< code lang="bash" >}}
docker ps -a
docker logs shadowsocks
{{< /code >}}

Revisa los registros en busca de mensajes de error. Los problemas comunes incluyen variables de entorno incorrectas o conflictos de puertos.

### No se puede acceder a la Pi desde fuera

1. Verifica que el reenvío de puertos esté configurado correctamente en tu router
2. Comprueba que tu IP pública coincida con lo que reporta ddclient: `curl https://api.ipify.org`
3. Comprueba que Nginx esté escuchando: `sudo ss -tlnp | grep 443`
4. Revisa el cortafuegos (si está activado): `sudo ufw status`

### El certificado SSL falla

- Asegúrate de que tu dominio resuelva a tu IP doméstica: `nslookup YOUR_DOMAIN`
- Asegúrate de que el puerto 80 esté reenviado y Nginx esté en ejecución
- Inténtalo de nuevo: `sudo certbot --nginx -d YOUR_DOMAIN`

### Velocidades lentas

- Usa Ethernet en lugar de WiFi
- Comprueba la velocidad de subida de tu internet doméstico -- este es el cuello de botella para un proxy alojado en casa
- Asegúrate de que no haya otros servicios pesados ejecutándose en la Pi

### La conexión funciona pero se corta frecuentemente

- Comprueba la temperatura de la Pi: `vcgencmd measure_temp` (debería estar por debajo de 80 °C)
- Comprueba la memoria disponible: `free -m`
- Revisa los registros de Nginx: `sudo tail -f /var/log/nginx/error.log`

---

## ¿Y ahora qué?

- **[Conecta todos tus dispositivos](/es/guides/configurar-cliente/)** -- Configura clientes en Windows, macOS, Linux, Android e iOS
- **[¿Por qué Shadowsocks?](/es/por-que-shadowsocks/)** -- Aprende más sobre la tecnología y cómo resiste la censura
- Considera configurar **actualizaciones desatendidas** para mantener el sistema operativo de tu Pi actualizado automáticamente:

{{< code lang="bash" >}}
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
{{< /code >}}
