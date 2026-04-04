---
title: "Desplegar Shadowsocks en un VPS"
description: "Pon en marcha tu propio proxy cifrado en menos de 20 minutos con esta guía paso a paso."
slug: "configurar-vps"
layout: "guides/single"
estimated_time: 20
difficulty: "beginner"
mermaid: true
prerequisites:
  - "Conocimientos básicos de terminal/línea de comandos"
  - "Una tarjeta de crédito para el dominio y alquiler de VPS"
---

## Descripción general de la arquitectura

Antes de empezar, veamos lo que vamos a construir. Cada componente cumple una función específica para hacer que tu tráfico sea invisible para censores e ISP:

{{< mermaid >}}
graph TD
    A["Tu Dispositivo"] -->|"HTTPS :443"| B["Nginx"]
    B -->|"WebSocket"| C["Shadowsocks :8389"]
    C -->|"Tráfico Normal"| D["Internet"]
    style A fill:#1e293b,stroke:#3b82f6,color:#e2e8f0
    style B fill:#1e293b,stroke:#f59e0b,color:#e2e8f0
    style C fill:#1e293b,stroke:#10b981,color:#e2e8f0
    style D fill:#1e293b,stroke:#8b5cf6,color:#e2e8f0
{{< /mermaid >}}

- **Nginx** escucha en el puerto 443 con un certificado SSL genuino, gestionando la terminación TLS. Para cualquier observador, tu servidor parece un sitio web HTTPS normal.
- **Shadowsocks** se ejecuta dentro de un contenedor Docker en el puerto 8389 (solo localhost). Nginx reenvía el tráfico WebSocket desde la ruta `/shadowsocks` a este contenedor.
- **v2ray-plugin** envuelve el protocolo Shadowsocks dentro de marcos WebSocket, así que la cadena completa es: tu dispositivo &rarr; TLS &rarr; WebSocket &rarr; Shadowsocks &rarr; internet.

El resultado: tu ISP ve tráfico HTTPS estándar dirigido a lo que parece un sitio web ordinario. No hay nada que detectar ni bloquear.

---

## Paso 1: Compra un nombre de dominio

Necesitas un nombre de dominio para tu servidor proxy. Es esencial — te permite obtener un certificado SSL real, lo que hace que tu tráfico parezca navegación HTTPS normal. Sin un dominio, los firewalls pueden identificar y bloquear fácilmente tu servidor por IP.

Un dominio cuesta tan solo **$2-9 al año**. Elige cualquier registrador:

{{< tabs names="Namecheap,Cloudflare,Porkbun" >}}

{{< tab index="0" >}}
**Namecheap** — Dominios económicos con protección de privacidad gratuita.

1. Ve a [namecheap.com](#) y busca un dominio
2. Elige un TLD barato (`.uk`, `.xyz`, `.site` suelen costar menos de $3/año)
3. Añade **WhoisGuard** (gratis) para ocultar tu información personal
4. Completa la compra
5. Ve a **Domain List** → tu dominio → **Advanced DNS** para gestionar registros DNS

{{< alert type="tip" >}}
Elige un nombre de dominio genérico e inocente. Evita palabras como "vpn", "proxy" o "bypass" — quieres que tu servidor parezca un sitio web cualquiera.
{{< /alert >}}

{{< /tab >}}

{{< tab index="1" >}}
**Cloudflare Registrar** — Dominios a precio de coste, sin margen.

1. Crea una cuenta en [cloudflare.com](#)
2. Ve a **Domain Registration** → **Register Domain**
3. Busca un dominio y cómpralo (`.com` cuesta ~$9/año a precio de coste)
4. El DNS se gestiona automáticamente desde Cloudflare — no necesitas configuración adicional

{{< alert type="info" >}}
Cloudflare también te da CDN gratis, protección DDoS y gestión de DNS. Esto añade una capa extra de protección para tu servidor proxy.
{{< /alert >}}

{{< /tab >}}

{{< tab index="2" >}}
**Porkbun** — Precios bajos, privacidad WHOIS y SSL incluidos gratis.

1. Ve a [porkbun.com](#) y busca un dominio
2. Muchos TLDs están disponibles por menos de $5/año
3. La privacidad WHOIS está incluida gratis con cada dominio
4. Completa la compra y gestiona el DNS desde el panel

{{< /tab >}}

{{< /tabs >}}

{{< alert type="warning" >}}
**La privacidad importa.** Activa siempre la protección de privacidad WHOIS (gratis en todos los registradores anteriores). Esto oculta tu nombre, dirección y email de la base de datos pública de WHOIS.
{{< /alert >}}

---

## Paso 2: Elige un proveedor de VPS

Necesitas un servidor privado virtual (VPS) -- un pequeño ordenador en la nube que ejecutará tu proxy Shadowsocks las 24 horas del día, los 7 días de la semana. El plan más barato de cualquier proveedor importante es más que suficiente.

{{< tabs names="DigitalOcean,Vultr,Hetzner,OVH" >}}

{{< tab index="0" >}}
**DigitalOcean** -- Fiable, fácil para principiantes, servidores en más de 15 regiones.

1. Regístrate en [digitalocean.com](https://digitalocean.com)
2. Haz clic en **Create Droplet**
3. Elige **Ubuntu 24.04 LTS** como sistema operativo
4. Selecciona el plan de **$4/mes** (512 MB RAM, 1 vCPU) -- esto es más que suficiente
5. Elige una región cercana a ti (por ejemplo, Londres, Fráncfort, Nueva York)
6. En **Authentication**, selecciona **SSH Key** (recomendado) o **Password**
7. Haz clic en **Create Droplet** y anota la dirección IP
{{< /tab >}}

{{< tab index="1" >}}
**Vultr** -- Precios competitivos, 32 ubicaciones de servidores en todo el mundo.

1. Regístrate en [vultr.com](https://vultr.com)
2. Haz clic en **Deploy New Server**
3. Elige **Cloud Compute (Regular Performance)**
4. Selecciona **Ubuntu 24.04 LTS**
5. Elige el plan de **$3.50/mes** (512 MB RAM, 1 vCPU)
6. Selecciona una ubicación de servidor cercana a ti
7. Añade tu clave SSH o establece una contraseña de root
8. Haz clic en **Deploy Now** y anota la dirección IP
{{< /tab >}}

{{< tab index="2" >}}
**Hetzner** -- Excelente relación calidad-precio, con sede en la UE, fuerte privacidad.

1. Regístrate en [hetzner.com/cloud](https://hetzner.com/cloud)
2. Crea un nuevo proyecto, luego haz clic en **Add Server**
3. Elige **Ubuntu 24.04** como imagen
4. Selecciona **CX22** (2 vCPU, 4 GB RAM, aproximadamente 4 EUR/mes) o el más barato disponible
5. Elige una ubicación (Falkenstein, Núremberg, Helsinki o Ashburn)
6. Añade tu clave SSH
7. Haz clic en **Create & Buy Now** y anota la dirección IP
{{< /tab >}}

{{< tab index="3" >}}
**OVH** -- Económico, con sede en la UE, ideal para usuarios preocupados por la privacidad.

1. Regístrate en [ovhcloud.com](https://ovhcloud.com)
2. Navega a **Public Cloud** &rarr; **Create an instance**
3. Elige **Ubuntu 24.04** como imagen
4. Selecciona el plan **Starter** (aproximadamente 3,50 EUR/mes)
5. Elige una región (Gravelines, Estrasburgo, Londres, etc.)
6. Añade tu clave SSH
7. Lanza la instancia y anota la dirección IP
{{< /tab >}}

{{< /tabs >}}

{{< alert type="tip" >}}
**¿Qué proveedor debería elegir?** Si no estás seguro, elige DigitalOcean o Vultr -- son los más fáciles para principiantes. Si estás en Europa y te importa la soberanía de datos, Hetzner es una excelente opción.
{{< /alert >}}

---

## Paso 3: Apunta tu dominio al servidor

Necesitas un nombre de dominio apuntando a tu VPS para poder obtener un certificado SSL genuino. Esto es lo que hace que tu tráfico parezca navegación HTTPS normal.

1. Inicia sesión en tu registrador de dominios (Namecheap, Cloudflare, GoDaddy, etc.)
2. Ve a la **configuración DNS** de tu dominio
3. Crea un **registro A**:
   - **Nombre/Host:** `@` (o un subdominio como `proxy`)
   - **Valor/Apunta a:** la dirección IP de tu VPS (por ejemplo, `203.0.113.42`)
   - **TTL:** Automático o 300 segundos

{{< alert type="info" >}}
Los cambios DNS pueden tardar hasta 24 horas en propagarse a nivel mundial, pero normalmente se completan en 5-10 minutos. Puedes comprobar la propagación en [dnschecker.org](https://dnschecker.org).
{{< /alert >}}

---

## Paso 4: Conéctate a tu servidor por SSH

Abre un terminal en tu ordenador y conéctate a tu VPS:

{{< code lang="bash" >}}
ssh root@YOUR_SERVER_IP
{{< /code >}}

Reemplaza `YOUR_SERVER_IP` con la dirección IP del Paso 2. Si configuraste una contraseña en lugar de una clave SSH, se te pedirá que la introduzcas.

{{< alert type="tip" >}}
**Usuarios de Windows:** Windows 10 y 11 incluyen un cliente SSH integrado. Abre **Terminal** o **PowerShell** y usa el mismo comando `ssh` de arriba. Alternativamente, puedes usar [PuTTY](https://putty.org/) si prefieres una interfaz gráfica.
{{< /alert >}}

Una vez conectado, deberías ver un prompt de comandos como `root@your-server:~#`. Ya estás listo para configurar el servidor.

---

## Paso 5: Instala Docker

Docker nos permite ejecutar Shadowsocks en un contenedor aislado. Instálalo con un solo comando:

{{< code lang="bash" >}}
curl -fsSL https://get.docker.com | sh
{{< /code >}}

Esto descarga y ejecuta el script de instalación oficial de Docker. Funciona en Ubuntu, Debian, CentOS y Fedora. El proceso tarda aproximadamente un minuto.

Verifica que Docker esté instalado y en ejecución:

{{< code lang="bash" >}}
docker --version
{{< /code >}}

Deberías ver una salida como `Docker version 27.x.x, build ...`.

---

## Paso 6: Despliega el contenedor Shadowsocks

Ahora despliega el servidor Shadowsocks con soporte de v2ray-plugin:

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
**¡Cambia la contraseña!** Reemplaza `YOUR_STRONG_PASSWORD` con una contraseña fuerte y única. Usa al menos 16 caracteres con una mezcla de letras, números y símbolos. Esta contraseña es la que cifra tu tráfico -- trátala como una contraseña bancaria.
{{< /alert >}}

Desglosemos lo que hace este comando:

- `-d` -- Ejecuta el contenedor en segundo plano (modo desacoplado)
- `--name shadowsocks` -- Da al contenedor un nombre fácil de recordar
- `--restart always` -- Reinicia automáticamente si el contenedor o servidor se reinicia
- `-p 127.0.0.1:8389:8389` -- Expone el puerto 8389 solo en localhost (no a internet público)
- `-e PASSWORD=...` -- Establece la contraseña de cifrado
- `-e METHOD=aes-256-gcm` -- Usa cifrado AES-256-GCM (el más fuerte disponible)

Verifica que el contenedor esté en ejecución:

{{< code lang="bash" >}}
docker ps
{{< /code >}}

Deberías ver un contenedor llamado `shadowsocks` con estado `Up`.

---

## Paso 7: Instala y configura Nginx

Nginx actuará como proxy inverso, aceptando conexiones HTTPS en el puerto 443 y reenviando el tráfico WebSocket al contenedor Shadowsocks.

Instala Nginx:

{{< code lang="bash" >}}
apt update && apt install -y nginx
{{< /code >}}

Crea el archivo de configuración de Nginx para tu dominio:

{{< code lang="bash" >}}
nano /etc/nginx/sites-available/YOUR_DOMAIN
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
ln -s /etc/nginx/sites-available/YOUR_DOMAIN /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
{{< /code >}}

{{< alert type="info" >}}
El bloque `location /` sirve una respuesta de texto simple para cualquier persona que visite tu dominio directamente. Esto hace que parezca un servidor web normal e inofensivo. Puedes reemplazarlo con una página HTML estática si lo prefieres.
{{< /alert >}}

---

## Paso 8: Obtén un certificado SSL

Un certificado SSL genuino de Let's Encrypt es fundamental. Asegura que tu tráfico use cifrado TLS real y que tu servidor parezca un sitio web HTTPS legítimo.

Instala Certbot y obtén un certificado:

{{< code lang="bash" >}}
apt install -y certbot python3-certbot-nginx
certbot --nginx -d YOUR_DOMAIN
{{< /code >}}

Certbot hará lo siguiente:
1. Verificar que controlas el dominio
2. Obtener un certificado SSL gratuito de Let's Encrypt
3. Configurar automáticamente Nginx para usar HTTPS
4. Configurar la renovación automática del certificado (los certificados caducan cada 90 días, pero Certbot los renueva automáticamente)

Cuando se te solicite, introduce tu dirección de correo electrónico (para notificaciones de renovación) y acepta los términos de servicio. Cuando se te pregunte sobre redirigir HTTP a HTTPS, selecciona **Sí** (opción 2).

{{< alert type="tip" >}}
Asegúrate de que el DNS de tu dominio esté completamente propagado antes de ejecutar Certbot. Si Certbot falla con un error de verificación de dominio, espera unos minutos e inténtalo de nuevo.
{{< /alert >}}

---

## Paso 9: Prueba tu configuración

### Verifica el servidor

Visita `https://YOUR_DOMAIN` en un navegador web. Deberías ver:
- Un certificado SSL válido (icono de candado en la barra de direcciones)
- El texto "Welcome to my website" (o lo que hayas configurado)

### Configura tu cliente

Ahora configura el cliente Shadowsocks en tu dispositivo. Necesitarás estos datos:

| Configuración | Valor |
|---|---|
| **Servidor** | `YOUR_DOMAIN` |
| **Puerto del servidor** | `443` |
| **Contraseña** | La contraseña que estableciste en el Paso 6 |
| **Cifrado** | `aes-256-gcm` |
| **Plugin** | `v2ray-plugin` |
| **Opciones del plugin** | `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0` |

{{< alert type="info" >}}
Para instrucciones detalladas de configuración del cliente en cada plataforma (Windows, macOS, Linux, Android, iOS), consulta nuestra guía [Conectar desde cualquier dispositivo](/es/guides/configurar-cliente/).
{{< /alert >}}

### Verifica la conexión

Una vez conectado a través de tu cliente Shadowsocks:

1. Visita [whatismyipaddress.com](https://whatismyipaddress.com) -- deberías ver la dirección IP de tu VPS, no la tuya real
2. Visita [dnsleaktest.com](https://dnsleaktest.com) y ejecuta el test extendido -- ninguna consulta DNS debería apuntar a tu ISP real
3. Ejecuta un test de velocidad en [speedtest.net](https://speedtest.net) -- deberías ver una reducción mínima de velocidad

---

## ¿Y ahora qué?

Tu proxy Shadowsocks ya está en funcionamiento. Aquí tienes algunos pasos siguientes:

- **[Conecta todos tus dispositivos](/es/guides/configurar-cliente/)** -- Configura el cliente en Windows, macOS, Linux, Android e iOS
- **[Aprende más sobre Shadowsocks](/es/por-que-shadowsocks/)** -- Comprende cómo funciona la tecnología y por qué es resistente a la censura
- **Configura actualizaciones automáticas** -- Mantén tu imagen Docker actualizada:

{{< code lang="bash" >}}
docker pull jfca68/shadowsocks-server:latest
docker stop shadowsocks && docker rm shadowsocks
# Re-run the docker run command from Step 6
{{< /code >}}

{{< alert type="tip" >}}
**Guarda esta página en favoritos.** Si alguna vez necesitas reconstruir tu servidor o solucionar un problema, todos los comandos que necesitas están aquí mismo.
{{< /alert >}}
