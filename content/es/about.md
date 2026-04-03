---
title: "Acerca de SkipRestriction"
description: "Conoce el proyecto SkipRestriction, nuestra misión y la tecnología de código abierto detrás de él."
ads: false
---

## Nuestra misión

SkipRestriction existe para ayudar a las personas a recuperar su libertad en internet. Creemos que el acceso a la información es un derecho fundamental, y que ningún gobierno, ISP o institución debería tener el poder de decidir qué puedes y qué no puedes ver en línea.

Proporcionamos guías gratuitas y de código abierto que te guían paso a paso para configurar tu propio servidor proxy cifrado Shadowsocks -- desde el principio hasta el final. No se requiere conocimiento técnico previo. Si puedes seguir instrucciones y escribir comandos en un terminal, puedes tener tu propia conexión a internet privada y resistente a la censura en menos de 20 minutos.

## Lo que ofrecemos

- **Guías gratuitas y completas** para desplegar Shadowsocks en un VPS o Raspberry Pi
- **Configuración de cliente multiplataforma** con instrucciones para Windows, macOS, Linux, Android e iOS
- **Soporte multilingüe** -- todas las guías están disponibles en inglés, ruso y español
- **Todo de código abierto** -- nuestras guías, imagen Docker y sitio web están disponibles libremente

No vendemos nada. No recopilamos tus datos. No ejecutamos servidores proxy en tu nombre. Nuestro objetivo es simplemente darte el conocimiento y las herramientas para hacerlo tú mismo.

## La tecnología

Nuestras guías utilizan una pila cuidadosamente seleccionada de tecnologías probadas y de código abierto:

- **[shadowsocks-libev](https://github.com/shadowsocks/shadowsocks-libev)** -- La implementación estándar en C del protocolo Shadowsocks. Ligera, rápida y probada en combate en millones de despliegues.
- **[v2ray-plugin](https://github.com/shadowsocks/v2ray-plugin)** -- Un plugin que envuelve el tráfico Shadowsocks dentro de WebSocket sobre TLS, haciéndolo indistinguible de la navegación HTTPS normal.
- **[Docker](https://www.docker.com/)** -- Nuestra imagen Docker personalizada ([jfca68/shadowsocks-server](https://hub.docker.com/r/jfca68/shadowsocks-server)) empaqueta todo en un único contenedor que se ejecuta de forma idéntica en cualquier plataforma -- VPS, Raspberry Pi o cualquier otro sistema que soporte Docker.
- **[Nginx](https://nginx.org/)** -- Actúa como proxy inverso, gestionando la terminación TLS y reenviando el tráfico WebSocket al contenedor Shadowsocks.
- **[Let's Encrypt](https://letsencrypt.org/)** -- Proporciona certificados SSL gratuitos con renovación automática a través de Certbot.

## Contacto y contribuciones

SkipRestriction es un proyecto de código abierto. Puedes encontrar todo nuestro código, reportar problemas y contribuir en GitHub:

- **Imagen Docker:** [github.com/JFCaBa/shadowsocks-server](https://github.com/JFCaBa/shadowsocks-server)
- **Código fuente del sitio web:** [github.com/JFCaBa/skiprestriction](https://github.com/JFCaBa/skiprestriction)

Si encuentras un error, tienes una sugerencia o quieres ayudar a traducir las guías a otros idiomas, por favor abre un issue o envía un pull request. Las contribuciones de todo tipo son bienvenidas.
