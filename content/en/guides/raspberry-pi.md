---
title: "Deploy Shadowsocks on a Raspberry Pi"
description: "Self-host your own encrypted proxy at home with a Raspberry Pi — zero monthly cost."
layout: "guides/single"
estimated_time: 30
difficulty: "beginner"
mermaid: true
prerequisites:
  - "A Raspberry Pi 3B+ or newer (Pi 4 recommended)"
  - "A microSD card (16GB+)"
  - "Ethernet cable or WiFi connection"
  - "A domain name"
  - "Access to your router's admin panel"
---

## Hardware Requirements

Before you start, make sure you have the following:

| Component | Minimum | Recommended |
|---|---|---|
| **Raspberry Pi** | Pi 3B+ | Pi 4 (2 GB+ RAM) |
| **Storage** | 16 GB microSD | 32 GB microSD (Class 10 / A2) |
| **Power supply** | 5V 2.5A (Pi 3) | 5V 3A USB-C (Pi 4) |
| **Network** | WiFi | Ethernet (more stable) |
| **Case** | Optional | Recommended (with passive cooling) |

Any Raspberry Pi from the 3B+ onwards has enough power to run Shadowsocks comfortably. The Pi handles encryption in hardware via its ARM processor's AES extensions, so even the cheapest model can saturate most home internet connections.

---

## How It Works

When you host Shadowsocks on a Raspberry Pi at home, traffic flows through your home internet connection. Here is the architecture:

{{< mermaid >}}
graph TD
    A["External Device"] -->|"HTTPS :443"| B["Router"]
    B -->|"Port Forward"| C["Raspberry Pi"]
    C --> D["Nginx + Docker"]
    D --> E["Shadowsocks"]
    E -->|"Normal Traffic"| F["ISP → Internet"]
    style A fill:#1e293b,stroke:#3b82f6,color:#e2e8f0
    style B fill:#1e293b,stroke:#f59e0b,color:#e2e8f0
    style C fill:#1e293b,stroke:#10b981,color:#e2e8f0
    style D fill:#1e293b,stroke:#8b5cf6,color:#e2e8f0
    style E fill:#1e293b,stroke:#ec4899,color:#e2e8f0
    style F fill:#1e293b,stroke:#6366f1,color:#e2e8f0
{{< /mermaid >}}

1. Your device connects to your domain over HTTPS (port 443)
2. Your router forwards port 443 to the Raspberry Pi's local IP
3. Nginx on the Pi handles TLS and forwards WebSocket traffic to the Shadowsocks container
4. Shadowsocks decrypts your request and sends it to the internet through your home ISP

The key advantage: **zero monthly cost**. Once the Pi is set up, it runs 24/7 using about 3-5 watts of electricity (roughly $1-2 per year). The only requirement is that your home internet connection stays online.

---

## Step 1: Flash Raspberry Pi OS

1. Download and install the **[Raspberry Pi Imager](https://www.raspberrypi.com/software/)** on your computer (available for Windows, macOS, and Linux)
2. Insert your microSD card into your computer
3. Open Raspberry Pi Imager and configure:
   - **Operating System:** Raspberry Pi OS Lite (64-bit) -- the "Lite" version has no desktop environment and uses fewer resources
   - **Storage:** Select your microSD card
4. Click the **gear icon** (or press Ctrl+Shift+X) to open advanced settings:
   - **Enable SSH** and set a password (or add your public SSH key)
   - **Set hostname** to something memorable (e.g., `shadowsocks-pi`)
   - **Configure WiFi** if you are not using Ethernet
5. Click **Write** and wait for the process to complete
6. Insert the microSD card into your Raspberry Pi and power it on

{{< alert type="tip" >}}
**Use Ethernet if possible.** A wired connection is more stable and faster than WiFi, which matters for a server that runs 24/7. If you must use WiFi, make sure the Pi has a strong signal.
{{< /alert >}}

---

## Step 2: Connect via SSH

Wait about 60 seconds for the Pi to boot, then connect from your computer:

{{< code lang="bash" >}}
ssh pi@shadowsocks-pi.local
{{< /code >}}

If `.local` hostname resolution does not work on your network, find the Pi's IP address from your router's admin page (usually at `192.168.1.1` or `192.168.0.1`) and connect using the IP directly:

{{< code lang="bash" >}}
ssh pi@192.168.1.XXX
{{< /code >}}

Once connected, update the system:

{{< code lang="bash" >}}
sudo apt update && sudo apt upgrade -y
{{< /code >}}

---

## Step 3: Set a Static IP Address

Your Raspberry Pi needs a fixed IP address on your local network so that port forwarding rules do not break when the Pi reboots.

Edit the DHCP client configuration:

{{< code lang="bash" >}}
sudo nano /etc/dhcpcd.conf
{{< /code >}}

Add the following at the end of the file (adjust the values for your network):

{{< code lang="bash" >}}
interface eth0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=1.1.1.1 8.8.8.8
{{< /code >}}

{{< alert type="info" >}}
If you are using WiFi instead of Ethernet, change `eth0` to `wlan0`. The `routers` value should be your router's IP address (usually `192.168.1.1` or `192.168.0.1`). Choose an `ip_address` that is outside your router's DHCP range to avoid conflicts.
{{< /alert >}}

Reboot to apply the changes:

{{< code lang="bash" >}}
sudo reboot
{{< /code >}}

Reconnect via SSH using the new static IP:

{{< code lang="bash" >}}
ssh pi@192.168.1.100
{{< /code >}}

---

## Step 4: Configure Port Forwarding

Your router needs to forward incoming traffic on ports 80 and 443 to your Raspberry Pi. This allows external connections to reach the Pi through your home IP address.

1. Log in to your router's admin panel (usually at `http://192.168.1.1`)
2. Find the **Port Forwarding** section (sometimes called "Virtual Servers" or "NAT Forwarding")
3. Create two forwarding rules:

| Service | External Port | Internal IP | Internal Port | Protocol |
|---|---|---|---|---|
| HTTP | 80 | 192.168.1.100 | 80 | TCP |
| HTTPS | 443 | 192.168.1.100 | 443 | TCP |

4. Save the settings

{{< alert type="warning" >}}
Port 80 is only needed temporarily for Let's Encrypt certificate validation. After obtaining your SSL certificate, you can remove the port 80 forwarding rule if you prefer, though keeping it allows automatic certificate renewal.
{{< /alert >}}

---

## Step 5: Set Up Dynamic DNS

Most home internet connections have a dynamic IP address that changes periodically. You need a way to keep your domain pointed at your current home IP. We will use **ddclient** with Cloudflare DNS.

Install ddclient:

{{< code lang="bash" >}}
sudo apt install -y ddclient
{{< /code >}}

During installation, the setup wizard will appear -- you can skip through it with default values. We will configure it manually.

Edit the ddclient configuration:

{{< code lang="bash" >}}
sudo nano /etc/ddclient.conf
{{< /code >}}

Replace the contents with (substitute your actual values):

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
To create a Cloudflare API token: log in to Cloudflare, go to **My Profile** &rarr; **API Tokens** &rarr; **Create Token**. Use the **Edit zone DNS** template and restrict it to your domain.
{{< /alert >}}

Restart ddclient and enable it on boot:

{{< code lang="bash" >}}
sudo systemctl restart ddclient
sudo systemctl enable ddclient
{{< /code >}}

Verify that it is working:

{{< code lang="bash" >}}
sudo ddclient -query
{{< /code >}}

This should show your current public IP address. The ddclient daemon will check for IP changes every 5 minutes by default and update your DNS record automatically.

---

## Step 6: Install Docker

Install Docker on the Raspberry Pi:

{{< code lang="bash" >}}
curl -fsSL https://get.docker.com | sh
{{< /code >}}

Add the `pi` user to the Docker group so you do not need `sudo` for Docker commands:

{{< code lang="bash" >}}
sudo usermod -aG docker pi
{{< /code >}}

Log out and log back in for the group change to take effect:

{{< code lang="bash" >}}
exit
ssh pi@192.168.1.100
{{< /code >}}

Verify Docker is running:

{{< code lang="bash" >}}
docker --version
{{< /code >}}

---

## Step 7: Deploy the Shadowsocks Container

Deploy the Shadowsocks server with v2ray-plugin support:

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
**Change the password!** Replace `YOUR_STRONG_PASSWORD` with a strong, unique password of at least 16 characters. This password encrypts all your traffic.
{{< /alert >}}

The Docker image is multi-architecture and automatically selects the correct ARM64 build for your Raspberry Pi. No special configuration is needed.

Verify the container is running:

{{< code lang="bash" >}}
docker ps
{{< /code >}}

You should see a container named `shadowsocks` with status `Up`.

---

## Step 8: Install and Configure Nginx

Install Nginx:

{{< code lang="bash" >}}
sudo apt install -y nginx
{{< /code >}}

Create the site configuration:

{{< code lang="bash" >}}
sudo nano /etc/nginx/sites-available/YOUR_DOMAIN
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
sudo ln -s /etc/nginx/sites-available/YOUR_DOMAIN /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
{{< /code >}}

---

## Step 9: Get an SSL Certificate

Install Certbot and obtain an SSL certificate:

{{< code lang="bash" >}}
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d YOUR_DOMAIN
{{< /code >}}

When prompted:
- Enter your email address for renewal notifications
- Agree to the terms of service
- Select **Yes** to redirect HTTP to HTTPS

Certbot will automatically configure Nginx for HTTPS and set up automatic certificate renewal.

{{< alert type="tip" >}}
Make sure your domain's DNS is pointed at your home IP and that port 80 is forwarded to the Pi before running Certbot. The verification process requires incoming HTTP connections.
{{< /alert >}}

---

## Step 10: Test Your Setup

### Test from an external network

{{< alert type="warning" >}}
**NAT loopback limitation:** Most home routers do not support NAT loopback (also called NAT hairpinning). This means you **cannot** test your Shadowsocks connection from inside your home network. You must test from an external network -- for example, using your phone's mobile data connection, or by asking someone on a different network to try.
{{< /alert >}}

1. Disconnect your phone from WiFi and use mobile data
2. Visit `https://YOUR_DOMAIN` in a browser -- you should see a valid SSL certificate and the "Welcome to my website" text
3. Configure the Shadowsocks client on your phone with these settings:

| Setting | Value |
|---|---|
| **Server** | `YOUR_DOMAIN` |
| **Server Port** | `443` |
| **Password** | The password from Step 7 |
| **Encryption** | `aes-256-gcm` |
| **Plugin** | `v2ray-plugin` |
| **Plugin Options** | `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0` |

For detailed client setup instructions, see our [Connect From Any Device](/en/guides/client-setup/) guide.

---

## Troubleshooting

### Docker container not running

{{< code lang="bash" >}}
docker ps -a
docker logs shadowsocks
{{< /code >}}

Check the logs for error messages. Common issues include incorrect environment variables or port conflicts.

### Cannot reach the Pi from outside

1. Verify port forwarding is configured correctly in your router
2. Check that your public IP matches what ddclient reports: `curl https://api.ipify.org`
3. Test that Nginx is listening: `sudo ss -tlnp | grep 443`
4. Check the firewall (if enabled): `sudo ufw status`

### SSL certificate fails

- Make sure your domain resolves to your home IP: `nslookup YOUR_DOMAIN`
- Make sure port 80 is forwarded and Nginx is running
- Try again: `sudo certbot --nginx -d YOUR_DOMAIN`

### Slow speeds

- Use Ethernet instead of WiFi
- Check your home internet upload speed -- this is the bottleneck for a home-hosted proxy
- Make sure no other heavy services are running on the Pi

### Connection works but drops frequently

- Check the Pi's temperature: `vcgencmd measure_temp` (should be below 80C)
- Check available memory: `free -m`
- Review Nginx logs: `sudo tail -f /var/log/nginx/error.log`

---

## What's Next?

- **[Connect all your devices](/en/guides/client-setup/)** -- Set up clients on Windows, macOS, Linux, Android, and iOS
- **[Why Shadowsocks?](/en/why-shadowsocks/)** -- Learn more about the technology and how it resists censorship
- Consider setting up **unattended upgrades** to keep your Pi's OS updated automatically:

{{< code lang="bash" >}}
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
{{< /code >}}
