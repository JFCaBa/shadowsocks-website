---
title: "Preguntas Frecuentes"
description: "Respuestas a preguntas comunes sobre Shadowsocks, privacidad, legalidad, detección y resolución de problemas."
layout: "single"
---

{{< faq-item question="¿Es legal Shadowsocks?" >}}
En la mayoría de los países, sí. Shadowsocks es una herramienta proxy, y el uso de software proxy es legal en la gran mayoría de jurisdicciones -- del mismo modo que usar HTTPS, túneles SSH o una VPN es legal. Sin embargo, algunos países tienen leyes que restringen o regulan el uso de herramientas de elusión. Por ejemplo, China, Rusia e Irán tienen regulaciones que teóricamente podrían usarse contra personas que utilizan estas herramientas, aunque la aplicación contra usuarios individuales es extremadamente rara y normalmente se dirige a proveedores comerciales.

**Importante:** Shadowsocks es una herramienta. Como cualquier herramienta, puede usarse para fines legales o ilegales. Te animamos encarecidamente a usarla de forma responsable y conforme a las leyes de tu país. La tecnología en sí es simplemente un proxy cifrado -- lo que importa es lo que hagas con ella.
{{< /faq-item >}}

{{< faq-item question="¿Es seguro Shadowsocks?" >}}
Sí. Shadowsocks utiliza cifrado **AES-256-GCM**, que es el mismo estándar de cifrado utilizado por bancos, gobiernos y organizaciones militares en todo el mundo. Se considera inquebrantable con la tecnología actual.

Cuando sigues nuestras guías, tu configuración también incluye:

- **Transporte WebSocket** a través del v2ray-plugin, que envuelve tu tráfico en un protocolo web estándar
- **Cifrado TLS 1.3** mediante un certificado SSL genuino de Let's Encrypt, añadiendo una segunda capa de cifrado
- **Tu propio servidor** que controlas completamente -- ningún tercero ve jamás tu tráfico sin cifrar

Este enfoque por capas (cifrado Shadowsocks dentro de WebSocket dentro de TLS) proporciona una privacidad más fuerte que la mayoría de los servicios VPN comerciales, porque tú controlas cada componente de la cadena.
{{< /faq-item >}}

{{< faq-item question="¿En qué se diferencia Shadowsocks de una VPN?" >}}
Aunque tanto Shadowsocks como las VPN cifran tu tráfico y lo enrutan a través de un servidor remoto, difieren en varios aspectos importantes:

- **Detección:** Los protocolos VPN (OpenVPN, WireGuard) tienen firmas reconocibles que los cortafuegos pueden detectar y bloquear fácilmente. Shadowsocks con v2ray-plugin parece tráfico HTTPS ordinario.
- **Control:** Con un servicio VPN, confías todo tu tráfico a una empresa. Con Shadowsocks, tú eres dueño y operas el servidor.
- **Sobrecarga:** Shadowsocks tiene menos sobrecarga de protocolo que las VPN, lo que resulta en velocidades más rápidas y menor latencia.
- **Alcance:** Las VPN normalmente enrutan todo el tráfico del dispositivo. Shadowsocks es un proxy SOCKS5, dándote control granular sobre qué aplicaciones lo utilizan.

Para una comparación detallada, consulta nuestra página [¿Por qué Shadowsocks?](/es/por-que-shadowsocks/).
{{< /faq-item >}}

{{< faq-item question="¿Puede mi ISP detectar que estoy usando Shadowsocks?" >}}
Cuando se configura con el v2ray-plugin (como en todas nuestras guías), tu tráfico Shadowsocks se envuelve dentro de una conexión HTTPS genuina utilizando un certificado SSL real y el protocolo WebSocket. Para tu ISP, el tráfico se ve idéntico al de alguien navegando en un sitio web normal.

Tu ISP puede ver que te estás conectando a la dirección IP de tu servidor y que la conexión usa HTTPS en el puerto 443, pero no puede determinar que la conexión transporta tráfico Shadowsocks. El cifrado, el certificado y el protocolo son todos genuinos -- no hay diferencia detectable entre tu tráfico proxy y la navegación web normal.

Incluso los sistemas de Inspección Profunda de Paquetes (DPI) utilizados por cortafuegos gubernamentales no pueden distinguir de forma fiable el tráfico Shadowsocks+v2ray del HTTPS legítimo.
{{< /faq-item >}}

{{< faq-item question="¿Qué pasa si mi ISP o gobierno bloquea la dirección IP de mi servidor?" >}}
El bloqueo basado en IP es la forma más simple de censura, y hay varias formas de sortearlo:

1. **Obtén un nuevo VPS.** La mayoría de los proveedores te permiten crear un nuevo servidor (con una nueva dirección IP) en minutos. Destruye el antiguo y redespliega.
2. **Usa la CDN de Cloudflare.** Apunta tu dominio a través de la CDN gratuita de Cloudflare. Tu tráfico se enrutará a través de la enorme red de direcciones IP de Cloudflare, haciendo que sea poco práctico bloquearlo sin interrumpir millones de sitios web legítimos.
3. **Cambia de proveedor o región.** Si el rango de IP de un proveedor en particular está bloqueado, prueba con un proveedor de VPS diferente o un servidor en otro país.
4. **Usa múltiples servidores.** Mantén dos o tres servidores en diferentes ubicaciones como respaldo. Si uno es bloqueado, cambia a otro al instante.

La ventaja clave de ejecutar tu propio servidor es que puedes adaptarte rápidamente. A diferencia de los servicios VPN comerciales cuyos rangos de IP son bien conocidos y bloqueados con frecuencia, tu servidor personal es uno entre millones de servidores web ordinarios.
{{< /faq-item >}}

{{< faq-item question="¿Qué tan rápido es Shadowsocks?" >}}
Shadowsocks es una de las soluciones proxy más rápidas disponibles. La velocidad real depende de varios factores:

- **Las especificaciones de tu VPS.** Incluso el VPS más barato (1 vCPU, 512 MB RAM) normalmente puede saturar una conexión de 1 Gbps sin dificultad.
- **Ubicación del servidor.** Elige un servidor geográficamente cercano a ti o al contenido que accedes para la menor latencia.
- **Tu velocidad de internet local.** Shadowsocks no puede hacer tu conexión más rápida de lo que proporciona tu ISP.

En la práctica, los usuarios normalmente experimentan **menos del 10% de reducción de velocidad** comparado con una conexión directa. Esto es significativamente mejor que la mayoría de los protocolos VPN, que a menudo introducen un 15-30% de sobrecarga. El cifrado AES-256-GCM tiene aceleración por hardware en prácticamente todos los procesadores modernos, por lo que el cifrado añade una latencia insignificante.
{{< /faq-item >}}

{{< faq-item question="¿Puedo compartir mi servidor Shadowsocks con amigos y familia?" >}}
Sí. Un único servidor Shadowsocks puede manejar muchas conexiones simultáneas sin ningún problema. La implementación `shadowsocks-libev` utilizada en nuestras guías es ligera y eficiente -- incluso un VPS básico puede soportar decenas de usuarios concurrentes.

Simplemente comparte los datos de conexión (dirección del servidor, puerto, contraseña, método de cifrado y configuración del plugin) con cualquier persona de tu confianza. Cada persona configura su propio cliente con los mismos datos.

**Una advertencia:** todos los que comparten tu servidor usan la misma contraseña e IP del servidor. Si necesitas credenciales separadas para diferentes usuarios o quieres monitorizar el uso por persona, considera ejecutar múltiples contenedores Shadowsocks con diferentes contraseñas en el mismo servidor.
{{< /faq-item >}}

{{< faq-item question="Mi conexión no funciona. ¿Cómo puedo solucionarlo?" >}}
Sigue estos pasos para diagnosticar el problema:

**1. Comprueba que el contenedor Docker esté en ejecución:**

```
docker ps
```

Deberías ver un contenedor llamado `shadowsocks` con estado "Up". Si no está en ejecución, revisa los registros:

```
docker logs shadowsocks
```

**2. Verifica la configuración de Shadowsocks:**
Asegúrate de que la contraseña, el método de cifrado (`aes-256-gcm`) y las opciones del plugin en tu cliente coincidan exactamente con lo que configuraste en el servidor. Incluso una diferencia de un solo carácter hará que la conexión falle silenciosamente.

**3. Revisa el cortafuegos:**

```
ufw status
```

Asegúrate de que los puertos 80 y 443 estén abiertos para tráfico TCP.

**4. Prueba Nginx:**

```
sudo nginx -t
```

Esto verifica la configuración de Nginx en busca de errores de sintaxis. Si reporta errores, revisa el archivo de configuración en `/etc/nginx/sites-available/tu-dominio`.

**5. Prueba el certificado SSL:**

Visita `https://tu-dominio.com` en un navegador web. Deberías ver la página predeterminada de Nginx con un certificado SSL válido (el icono del candado). Si el certificado es inválido, ejecuta de nuevo:

```
sudo certbot --nginx -d tu-dominio.com
```

**6. Prueba desde una red diferente:**

Si estás ejecutando Shadowsocks en una Raspberry Pi en casa, el NAT loopback puede impedirte conectar mientras estás en la misma red local. Prueba desde un teléfono móvil usando datos móviles, o pide a alguien en una red diferente que lo intente.

Si ninguno de estos pasos resuelve el problema, no dudes en abrir un issue en nuestro [repositorio de GitHub](https://github.com/JFCaBa/shadowsocks-server).
{{< /faq-item >}}
