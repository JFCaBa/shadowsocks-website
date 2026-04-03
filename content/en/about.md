---
title: "About SkipRestriction"
description: "Learn about the SkipRestriction project, our mission, and the open-source technology behind it."
ads: false
---

## Our Mission

SkipRestriction exists to help people reclaim their internet freedom. We believe that access to information is a fundamental right, and that no government, ISP, or institution should have the power to decide what you can and cannot see online.

We provide free, open-source guides that walk you through setting up your own encrypted Shadowsocks proxy server -- step by step, from start to finish. No technical background is required. If you can follow instructions and type commands into a terminal, you can have your own private, censorship-resistant internet connection in under 20 minutes.

## What We Provide

- **Free, comprehensive guides** for deploying Shadowsocks on a VPS or Raspberry Pi
- **Multi-platform client setup** instructions for Windows, macOS, Linux, Android, and iOS
- **Multi-language support** -- all guides are available in English, Russian, and Spanish
- **Open-source everything** -- our guides, Docker image, and website are all freely available

We do not sell anything. We do not collect your data. We do not run any proxy servers on your behalf. Our goal is simply to give you the knowledge and tools to do it yourself.

## The Technology

Our guides use a carefully chosen stack of proven, open-source technologies:

- **[shadowsocks-libev](https://github.com/shadowsocks/shadowsocks-libev)** -- The standard C implementation of the Shadowsocks protocol. Lightweight, fast, and battle-tested across millions of deployments.
- **[v2ray-plugin](https://github.com/shadowsocks/v2ray-plugin)** -- A plugin that wraps Shadowsocks traffic inside WebSocket over TLS, making it indistinguishable from normal HTTPS browsing.
- **[Docker](https://www.docker.com/)** -- Our custom Docker image ([jfca68/shadowsocks-server](https://hub.docker.com/r/jfca68/shadowsocks-server)) packages everything into a single container that runs identically on any platform -- VPS, Raspberry Pi, or anything else that supports Docker.
- **[Nginx](https://nginx.org/)** -- Acts as a reverse proxy, handling TLS termination and forwarding WebSocket traffic to the Shadowsocks container.
- **[Let's Encrypt](https://letsencrypt.org/)** -- Provides free, automatically-renewing SSL certificates via Certbot.

## Contact and Contributing

SkipRestriction is an open-source project. You can find all of our code, report issues, and contribute on GitHub:

- **Docker image:** [github.com/JFCaBa/shadowsocks-server](https://github.com/JFCaBa/shadowsocks-server)
- **Website source:** [github.com/JFCaBa/skiprestriction](https://github.com/JFCaBa/skiprestriction)

If you find a bug, have a suggestion, or want to help translate the guides into additional languages, please open an issue or submit a pull request. Contributions of all kinds are welcome.
