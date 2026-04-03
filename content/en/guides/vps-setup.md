---
title: "Deploy Shadowsocks on a VPS"
description: "Get your own encrypted proxy running in under 20 minutes with this step-by-step guide."
layout: "guides/single"
estimated_time: 20
difficulty: "beginner"
mermaid: true
prerequisites:
  - "A domain name (you can get one from Namecheap, Cloudflare, etc.)"
  - "Basic terminal/command line knowledge"
  - "A credit card for VPS rental"
---

## Architecture Overview

Before we begin, here is what we are building. Every component serves a specific purpose in making your traffic invisible to censors and ISPs:

{{< mermaid >}}
graph LR
    A["Your Device"] -->|"HTTPS :443"| B["Nginx"]
    B -->|"WebSocket"| C["Shadowsocks :8389"]
    C -->|"Normal Traffic"| D["Internet"]
    style A fill:#1e293b,stroke:#3b82f6,color:#e2e8f0
    style B fill:#1e293b,stroke:#f59e0b,color:#e2e8f0
    style C fill:#1e293b,stroke:#10b981,color:#e2e8f0
    style D fill:#1e293b,stroke:#8b5cf6,color:#e2e8f0
{{< /mermaid >}}

- **Nginx** listens on port 443 with a genuine SSL certificate, handling TLS termination. To any observer, your server looks like a normal HTTPS website.
- **Shadowsocks** runs inside a Docker container on port 8389 (localhost only). Nginx forwards WebSocket traffic from the `/shadowsocks` path to this container.
- **v2ray-plugin** wraps the Shadowsocks protocol inside WebSocket frames, so the entire chain is: your device &rarr; TLS &rarr; WebSocket &rarr; Shadowsocks &rarr; internet.

The result: your ISP sees standard HTTPS traffic to what appears to be an ordinary website. There is nothing to detect or block.

---

## Step 1: Choose a VPS Provider

You need a virtual private server (VPS) -- a small cloud computer that will run your Shadowsocks proxy 24/7. The cheapest tier from any major provider is more than sufficient.

{{< tabs names="DigitalOcean,Vultr,Hetzner,OVH" >}}

{{< tab index="0" >}}
**DigitalOcean** -- Reliable, beginner-friendly, servers in 15+ regions.

1. Sign up at [digitalocean.com](https://digitalocean.com)
2. Click **Create Droplet**
3. Choose **Ubuntu 24.04 LTS** as the operating system
4. Select the **$4/month** plan (512 MB RAM, 1 vCPU) -- this is more than enough
5. Choose a region close to you (e.g., London, Frankfurt, New York)
6. Under **Authentication**, select **SSH Key** (recommended) or **Password**
7. Click **Create Droplet** and note the IP address
{{< /tab >}}

{{< tab index="1" >}}
**Vultr** -- Competitive pricing, 32 server locations worldwide.

1. Sign up at [vultr.com](https://vultr.com)
2. Click **Deploy New Server**
3. Choose **Cloud Compute (Regular Performance)**
4. Select **Ubuntu 24.04 LTS**
5. Choose the **$3.50/month** plan (512 MB RAM, 1 vCPU)
6. Pick a server location close to you
7. Add your SSH key or set a root password
8. Click **Deploy Now** and note the IP address
{{< /tab >}}

{{< tab index="2" >}}
**Hetzner** -- Excellent value, EU-based, strong privacy.

1. Sign up at [hetzner.com/cloud](https://hetzner.com/cloud)
2. Create a new project, then click **Add Server**
3. Choose **Ubuntu 24.04** as the image
4. Select **CX22** (2 vCPU, 4 GB RAM, approximately EUR 4/month) or the cheapest available
5. Choose a location (Falkenstein, Nuremberg, Helsinki, or Ashburn)
6. Add your SSH key
7. Click **Create & Buy Now** and note the IP address
{{< /tab >}}

{{< tab index="3" >}}
**OVH** -- Budget-friendly, EU-based, good for privacy-conscious users.

1. Sign up at [ovhcloud.com](https://ovhcloud.com)
2. Navigate to **Public Cloud** &rarr; **Create an instance**
3. Choose **Ubuntu 24.04** as the image
4. Select the **Starter** tier (approximately EUR 3.50/month)
5. Choose a region (Gravelines, Strasbourg, London, etc.)
6. Add your SSH key
7. Launch the instance and note the IP address
{{< /tab >}}

{{< /tabs >}}

{{< alert type="tip" >}}
**Which provider should I choose?** If you are unsure, go with DigitalOcean or Vultr -- they are the most beginner-friendly. If you are in Europe and care about data sovereignty, Hetzner is an excellent choice.
{{< /alert >}}

---

## Step 2: Point Your Domain to the Server

You need a domain name pointed at your VPS so that you can get a genuine SSL certificate. This is what makes your traffic look like normal HTTPS browsing.

1. Log in to your domain registrar (Namecheap, Cloudflare, GoDaddy, etc.)
2. Go to the **DNS settings** for your domain
3. Create an **A record**:
   - **Name/Host:** `@` (or a subdomain like `proxy`)
   - **Value/Points to:** your VPS IP address (e.g., `203.0.113.42`)
   - **TTL:** Automatic or 300 seconds

{{< alert type="info" >}}
DNS changes can take up to 24 hours to propagate worldwide, but usually complete within 5-10 minutes. You can check propagation at [dnschecker.org](https://dnschecker.org).
{{< /alert >}}

---

## Step 3: Connect to Your Server via SSH

Open a terminal on your computer and connect to your VPS:

{{< code lang="bash" >}}
ssh root@YOUR_SERVER_IP
{{< /code >}}

Replace `YOUR_SERVER_IP` with the IP address from Step 1. If you set a password instead of an SSH key, you will be prompted to enter it.

{{< alert type="tip" >}}
**Windows users:** Windows 10 and 11 include a built-in SSH client. Open **Terminal** or **PowerShell** and use the same `ssh` command above. Alternatively, you can use [PuTTY](https://putty.org/) if you prefer a graphical interface.
{{< /alert >}}

Once connected, you should see a command prompt like `root@your-server:~#`. You are now ready to set up the server.

---

## Step 4: Install Docker

Docker lets us run Shadowsocks in an isolated container. Install it with a single command:

{{< code lang="bash" >}}
curl -fsSL https://get.docker.com | sh
{{< /code >}}

This downloads and runs Docker's official installation script. It works on Ubuntu, Debian, CentOS, and Fedora. The process takes about a minute.

Verify that Docker is installed and running:

{{< code lang="bash" >}}
docker --version
{{< /code >}}

You should see output like `Docker version 27.x.x, build ...`.

---

## Step 5: Deploy the Shadowsocks Container

Now deploy the Shadowsocks server with v2ray-plugin support:

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
**Change the password!** Replace `YOUR_STRONG_PASSWORD` with a strong, unique password. Use at least 16 characters with a mix of letters, numbers, and symbols. This password is what encrypts your traffic -- treat it like a bank password.
{{< /alert >}}

Let us break down what this command does:

- `-d` -- Run the container in the background (detached mode)
- `--name shadowsocks` -- Give the container a memorable name
- `--restart always` -- Automatically restart if the container or server reboots
- `-p 127.0.0.1:8389:8389` -- Expose port 8389 only on localhost (not to the public internet)
- `-e PASSWORD=...` -- Set the encryption password
- `-e METHOD=aes-256-gcm` -- Use AES-256-GCM encryption (the strongest available)

Verify the container is running:

{{< code lang="bash" >}}
docker ps
{{< /code >}}

You should see a container named `shadowsocks` with status `Up`.

---

## Step 6: Install and Configure Nginx

Nginx will act as a reverse proxy, accepting HTTPS connections on port 443 and forwarding WebSocket traffic to the Shadowsocks container.

Install Nginx:

{{< code lang="bash" >}}
apt update && apt install -y nginx
{{< /code >}}

Create the Nginx configuration file for your domain:

{{< code lang="bash" >}}
nano /etc/nginx/sites-available/YOUR_DOMAIN
{{< /code >}}

Paste the following configuration (replace `YOUR_DOMAIN` with your actual domain):

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

Enable the site and restart Nginx:

{{< code lang="bash" >}}
ln -s /etc/nginx/sites-available/YOUR_DOMAIN /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
{{< /code >}}

{{< alert type="info" >}}
The `location /` block serves a simple text response for anyone who visits your domain directly. This makes it look like a normal, innocuous web server. You can replace this with a static HTML page if you prefer.
{{< /alert >}}

---

## Step 7: Get an SSL Certificate

A genuine SSL certificate from Let's Encrypt is critical. It ensures your traffic uses real TLS encryption and that your server looks like a legitimate HTTPS website.

Install Certbot and obtain a certificate:

{{< code lang="bash" >}}
apt install -y certbot python3-certbot-nginx
certbot --nginx -d YOUR_DOMAIN
{{< /code >}}

Certbot will:
1. Verify that you control the domain
2. Obtain a free SSL certificate from Let's Encrypt
3. Automatically configure Nginx to use HTTPS
4. Set up automatic certificate renewal (certificates expire every 90 days, but Certbot renews them automatically)

When prompted, enter your email address (for renewal notifications) and agree to the terms of service. When asked about redirecting HTTP to HTTPS, select **Yes** (option 2).

{{< alert type="tip" >}}
Make sure your domain's DNS is fully propagated before running Certbot. If Certbot fails with a domain verification error, wait a few minutes and try again.
{{< /alert >}}

---

## Step 8: Test Your Setup

### Verify the server

Visit `https://YOUR_DOMAIN` in a web browser. You should see:
- A valid SSL certificate (padlock icon in the address bar)
- The "Welcome to my website" text (or whatever you configured)

### Configure your client

Now set up the Shadowsocks client on your device. You will need these details:

| Setting | Value |
|---|---|
| **Server** | `YOUR_DOMAIN` |
| **Server Port** | `443` |
| **Password** | The password you set in Step 5 |
| **Encryption** | `aes-256-gcm` |
| **Plugin** | `v2ray-plugin` |
| **Plugin Options** | `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0` |

{{< alert type="info" >}}
For detailed client setup instructions for every platform (Windows, macOS, Linux, Android, iOS), see our [Connect From Any Device](/en/guides/client-setup/) guide.
{{< /alert >}}

### Verify the connection

Once connected through your Shadowsocks client:

1. Visit [whatismyipaddress.com](https://whatismyipaddress.com) -- you should see your VPS's IP address, not your real one
2. Visit [dnsleaktest.com](https://dnsleaktest.com) and run the extended test -- no DNS queries should point to your real ISP
3. Run a speed test at [speedtest.net](https://speedtest.net) -- you should see minimal speed reduction

---

## What's Next?

Your Shadowsocks proxy is now running. Here are some next steps:

- **[Connect all your devices](/en/guides/client-setup/)** -- Set up the client on Windows, macOS, Linux, Android, and iOS
- **[Learn more about Shadowsocks](/en/why-shadowsocks/)** -- Understand how the technology works and why it is resistant to censorship
- **Set up automatic updates** -- Keep your Docker image up to date:

{{< code lang="bash" >}}
docker pull jfca68/shadowsocks-server:latest
docker stop shadowsocks && docker rm shadowsocks
# Re-run the docker run command from Step 5
{{< /code >}}

{{< alert type="tip" >}}
**Bookmark this page.** If you ever need to rebuild your server or troubleshoot an issue, all the commands you need are right here.
{{< /alert >}}
