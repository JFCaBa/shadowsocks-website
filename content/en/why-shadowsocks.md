---
title: "Why Shadowsocks?"
description: "Understand what Shadowsocks is, how it compares to a VPN, and why it remains one of the most effective tools for bypassing internet censorship."
mermaid: true
---

## What Is Shadowsocks?

Shadowsocks is a lightweight, encrypted proxy protocol created in 2012 by a Chinese developer known as "clowwindy." It was designed from the ground up for a single purpose: **circumventing internet censorship**. Unlike traditional VPNs that tunnel all of your traffic through a single encrypted connection, Shadowsocks acts as a SOCKS5 proxy that selectively routes your traffic through an encrypted channel to a server you control.

The project quickly gained popularity across China, Iran, Russia, and other countries where governments actively restrict internet access. Today, Shadowsocks is one of the most widely deployed anti-censorship tools in the world, with millions of active users. The protocol is fully open source, has been independently audited, and continues to be actively developed by a global community of contributors.

What sets Shadowsocks apart from other solutions is its focus on **stealth**. Rather than creating an obviously encrypted tunnel that draws attention, Shadowsocks is designed to make your traffic look indistinguishable from normal HTTPS web browsing. This makes it exceptionally difficult for network administrators, ISPs, and government censors to detect and block.

---

## How It Works

At its core, Shadowsocks creates an encrypted connection between your device and a proxy server that you control. When you browse the internet through Shadowsocks, your traffic flows like this:

{{< mermaid >}}
graph LR
    A["Your Device"] -->|"Encrypted Traffic"| B["Shadowsocks Server"]
    B -->|"Normal Traffic"| C["Internet"]
    D["Your ISP"] -.->|"Sees: Normal HTTPS"| A
    style A fill:#1e293b,stroke:#3b82f6,color:#e2e8f0
    style B fill:#1e293b,stroke:#10b981,color:#e2e8f0
    style C fill:#1e293b,stroke:#8b5cf6,color:#e2e8f0
    style D fill:#1e293b,stroke:#f59e0b,color:#e2e8f0
{{< /mermaid >}}

1. **Your device** encrypts your internet traffic using the AES-256-GCM cipher and sends it to your Shadowsocks server.
2. **The Shadowsocks server** decrypts the traffic and forwards it to the destination website or service as a normal request.
3. **Your ISP** only sees what looks like ordinary HTTPS traffic flowing to a regular web server. There is no detectable VPN signature, no unusual protocol fingerprint -- just normal-looking encrypted web traffic.

With the addition of the **v2ray-plugin**, your Shadowsocks traffic is wrapped inside a genuine WebSocket connection over TLS. This means the traffic is not just disguised -- it genuinely *is* HTTPS traffic carrying WebSocket frames, making it virtually impossible to distinguish from legitimate web browsing.

---

## Shadowsocks vs. VPN: A Detailed Comparison

Many people are familiar with commercial VPN services, so here is how Shadowsocks compares:

| Feature | Shadowsocks + v2ray | Commercial VPN |
|---|---|---|
| **Detection** | Extremely hard to detect; looks like HTTPS | Easily detected; known VPN protocols and IP ranges |
| **Speed** | Minimal overhead (<10% speed reduction) | Moderate overhead (15-30% speed reduction) |
| **Control** | Full control -- you own the server | Zero control -- the company controls everything |
| **Monthly Cost** | $3-6/month for a VPS | $5-12/month for a subscription |
| **Privacy** | No logs unless you enable them | "No-log" claims are unverifiable |
| **Logging** | You control the server, you control the logs | The VPN company can log everything |
| **Flexibility** | Fully customisable, any port, any server location | Limited to the provider's server locations |
| **Protocol** | SOCKS5 proxy with AES-256-GCM + TLS | OpenVPN, WireGuard, or proprietary protocols |

The fundamental advantage of Shadowsocks is **trust**. When you use a commercial VPN, you are trusting a company with all of your internet traffic. You have no way to verify their "no-log" policies, and multiple VPN providers have been caught [logging user data](https://en.wikipedia.org/wiki/Virtual_private_network#Security) despite promising otherwise. With Shadowsocks, the server is yours. You can inspect every line of configuration, every log entry, and every network connection.

---

## Why Shadowsocks Is Harder to Detect

Governments and ISPs use a technology called **Deep Packet Inspection (DPI)** to analyse internet traffic in real time. DPI examines the structure and patterns of network packets to identify and block specific protocols. This is how countries like China, Russia, and Iran block VPN connections -- they detect the characteristic handshake patterns and packet structures of VPN protocols such as OpenVPN and WireGuard, and drop or throttle the connections.

Shadowsocks was designed specifically to resist DPI analysis. Here is how:

- **No fixed handshake pattern.** Unlike VPN protocols that use recognisable handshake sequences, Shadowsocks traffic has no predictable pattern that DPI systems can match against.
- **Encrypted from the first byte.** The entire Shadowsocks stream is encrypted, including the initial connection setup. There is no unencrypted metadata that leaks information about the protocol.
- **v2ray-plugin adds genuine TLS.** When you use the v2ray-plugin (which all of our guides configure), your Shadowsocks traffic is wrapped inside a real TLS 1.3 connection using a real SSL certificate for your domain. The traffic is transported over WebSocket, a standard web technology used by millions of websites for real-time features like chat and notifications.
- **Indistinguishable from HTTPS.** To any observer -- whether it is your ISP, a government firewall, or a network administrator -- your Shadowsocks traffic looks identical to someone browsing a normal HTTPS website. Because the TLS certificate is real and the WebSocket protocol is genuine, even active probing attacks cannot distinguish your proxy traffic from legitimate web traffic.

This layered approach makes Shadowsocks with v2ray-plugin one of the most censorship-resistant tools available today. While even the Great Firewall of China can detect and block standard VPN protocols within seconds, Shadowsocks with proper obfuscation continues to operate reliably.

---

## Use Cases

### Bypassing Government Censorship

In countries like Russia, China, Iran, and Turkmenistan, governments block access to thousands of websites and services -- including news outlets, social media platforms, and messaging applications. Shadowsocks provides a reliable, hard-to-detect method for accessing the open internet. Because you control the server, there is no third party that can be pressured to hand over your data or shut down access.

### Protecting Your Privacy

Even in countries without overt censorship, ISPs routinely monitor and log your browsing activity. They sell this data to advertisers, hand it over to government agencies, and use it to shape your internet experience. Routing your traffic through your own Shadowsocks server ensures your ISP sees nothing but encrypted traffic to what appears to be an ordinary web server.

### Travelling Abroad

When travelling to countries with restrictive internet policies, having a pre-configured Shadowsocks server gives you instant, reliable access to all the services you use at home. Unlike commercial VPNs that are frequently blocked in restrictive countries, Shadowsocks with v2ray-plugin consistently works even in the most censored environments.

### School and Workplace Networks

Many schools, universities, and workplaces block access to websites and services using the same DPI technology that governments use. Shadowsocks traffic passes through these filters because it is indistinguishable from normal HTTPS browsing. From the network administrator's perspective, you are simply visiting a website.

---

## Get Started

Setting up your own Shadowsocks server takes less than 20 minutes. Follow one of our step-by-step guides:

- **[Deploy on a VPS](/en/guides/vps-setup/)** -- The recommended approach. Get a cloud server running for about $5/month with servers in 20+ countries.
- **[Deploy on a Raspberry Pi](/en/guides/raspberry-pi/)** -- Self-host at home with zero monthly cost. Perfect if you already have a Pi.
- **[Connect from any device](/en/guides/client-setup/)** -- Set up the Shadowsocks client on Windows, macOS, Linux, Android, and iOS.
