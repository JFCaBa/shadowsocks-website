---
title: "Frequently Asked Questions"
description: "Answers to common questions about Shadowsocks, privacy, legality, detection, and troubleshooting."
layout: "single"
---

{{< faq-item question="Is Shadowsocks legal?" >}}
In most countries, yes. Shadowsocks is a proxy tool, and using proxy software is legal in the vast majority of jurisdictions -- just as using HTTPS, SSH tunnels, or a VPN is legal. However, some countries have laws that restrict or regulate the use of circumvention tools. For example, China, Russia, and Iran have regulations that could theoretically be used against individuals using such tools, though enforcement against individual users is extremely rare and typically targets commercial providers.

**Important:** Shadowsocks is a tool. Like any tool, it can be used for lawful or unlawful purposes. We strongly encourage you to use it responsibly and in accordance with the laws of your country. The technology itself is simply an encrypted proxy -- what matters is what you do with it.
{{< /faq-item >}}

{{< faq-item question="Is Shadowsocks safe?" >}}
Yes. Shadowsocks uses **AES-256-GCM** encryption, which is the same encryption standard used by banks, governments, and military organisations worldwide. It is considered unbreakable with current technology.

When you follow our guides, your setup also includes:

- **WebSocket transport** via the v2ray-plugin, which wraps your traffic in a standard web protocol
- **TLS 1.3 encryption** via a genuine SSL certificate from Let's Encrypt, adding a second layer of encryption
- **Your own server** that you fully control -- no third party ever sees your unencrypted traffic

This layered approach (Shadowsocks encryption inside WebSocket inside TLS) provides stronger privacy than most commercial VPN services, because you control every component of the chain.
{{< /faq-item >}}

{{< faq-item question="How is Shadowsocks different from a VPN?" >}}
While both Shadowsocks and VPNs encrypt your traffic and route it through a remote server, they differ in several important ways:

- **Detection:** VPN protocols (OpenVPN, WireGuard) have recognisable signatures that firewalls can easily detect and block. Shadowsocks with v2ray-plugin looks like ordinary HTTPS traffic.
- **Control:** With a VPN service, you trust a company with all your traffic. With Shadowsocks, you own and operate the server.
- **Overhead:** Shadowsocks has less protocol overhead than VPNs, resulting in faster speeds and lower latency.
- **Scope:** VPNs typically route all device traffic. Shadowsocks is a SOCKS5 proxy, giving you granular control over which applications use it.

For a detailed comparison, see our [Why Shadowsocks](/en/why-shadowsocks/) page.
{{< /faq-item >}}

{{< faq-item question="Can my ISP detect that I'm using Shadowsocks?" >}}
When configured with the v2ray-plugin (as in all of our guides), your Shadowsocks traffic is wrapped inside a genuine HTTPS connection using a real SSL certificate and the WebSocket protocol. To your ISP, the traffic looks identical to someone browsing a normal website.

Your ISP can see that you are connecting to your server's IP address and that the connection uses HTTPS on port 443, but they cannot determine that the connection is carrying Shadowsocks traffic. The encryption, certificate, and protocol are all genuine -- there is no detectable difference between your proxy traffic and normal web browsing.

Even Deep Packet Inspection (DPI) systems used by government firewalls cannot reliably distinguish Shadowsocks+v2ray traffic from legitimate HTTPS.
{{< /faq-item >}}

{{< faq-item question="What if my ISP or government blocks my server's IP address?" >}}
IP-based blocking is the simplest form of censorship, and there are several ways to work around it:

1. **Get a new VPS.** Most providers let you spin up a new server (with a new IP address) in minutes. Destroy the old one and redeploy.
2. **Use Cloudflare CDN.** Point your domain through Cloudflare's free CDN. Your traffic will route through Cloudflare's massive network of IP addresses, making it impractical to block without disrupting millions of legitimate websites.
3. **Switch providers or regions.** If a particular provider's IP range is blocked, try a different VPS provider or a server in a different country.
4. **Use multiple servers.** Maintain two or three servers in different locations as backups. If one is blocked, switch to another instantly.

The key advantage of running your own server is that you can adapt quickly. Unlike commercial VPN services whose IP ranges are well-known and frequently blocked, your personal server is one among millions of ordinary web servers.
{{< /faq-item >}}

{{< faq-item question="How fast is Shadowsocks?" >}}
Shadowsocks is one of the fastest proxy solutions available. The actual speed depends on several factors:

- **Your VPS specification.** Even the cheapest VPS (1 vCPU, 512 MB RAM) can typically saturate a 1 Gbps connection without difficulty.
- **Server location.** Choose a server geographically close to you or to the content you access for the lowest latency.
- **Your local internet speed.** Shadowsocks cannot make your connection faster than your ISP provides.

In practice, users typically experience **less than a 10% speed reduction** compared to a direct connection. This is significantly better than most VPN protocols, which often introduce 15-30% overhead. The AES-256-GCM cipher is hardware-accelerated on virtually all modern processors, so encryption adds negligible latency.
{{< /faq-item >}}

{{< faq-item question="Can I share my Shadowsocks server with friends and family?" >}}
Yes. A single Shadowsocks server can handle many simultaneous connections without any issues. The `shadowsocks-libev` implementation used in our guides is lightweight and efficient -- even a basic VPS can support dozens of concurrent users.

Simply share your connection details (server address, port, password, encryption method, and plugin settings) with anyone you trust. Each person configures their own client with the same details.

**A word of caution:** everyone who shares your server uses the same password and server IP. If you need separate credentials for different users or want to monitor usage per person, consider running multiple Shadowsocks containers with different passwords on the same server.
{{< /faq-item >}}

{{< faq-item question="My connection is not working. How do I troubleshoot?" >}}
Follow these steps to diagnose the problem:

**1. Check that the Docker container is running:**

```
docker ps
```

You should see a container named `shadowsocks` with status "Up." If it is not running, check the logs:

```
docker logs shadowsocks
```

**2. Verify your Shadowsocks configuration:**
Make sure the password, encryption method (`aes-256-gcm`), and plugin options in your client match exactly what you configured on the server. Even a single character difference will cause the connection to fail silently.

**3. Check the firewall:**

```
ufw status
```

Ensure ports 80 and 443 are open for TCP traffic.

**4. Test Nginx:**

```
sudo nginx -t
```

This checks your Nginx configuration for syntax errors. If it reports errors, review the configuration file at `/etc/nginx/sites-available/your-domain`.

**5. Test SSL certificate:**

Visit `https://your-domain.com` in a web browser. You should see the default Nginx page with a valid SSL certificate (the padlock icon). If the certificate is invalid, re-run:

```
sudo certbot --nginx -d your-domain.com
```

**6. Test from a different network:**

If you are running Shadowsocks on a Raspberry Pi at home, NAT loopback may prevent you from connecting while on the same local network. Test from a mobile phone using mobile data, or ask someone on a different network to try.

If none of these steps resolve the issue, feel free to open an issue on our [GitHub repository](https://github.com/JFCaBa/shadowsocks-server).
{{< /faq-item >}}
