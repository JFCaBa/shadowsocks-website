---
title: "Connect From Any Device"
description: "Set up the Shadowsocks client on Windows, macOS, Linux, Android, and iOS."
layout: "guides/single"
estimated_time: 10
difficulty: "beginner"
prerequisites:
  - "A running Shadowsocks server (see VPS Setup or Raspberry Pi guides)"
  - "Your server details: address, password, encryption method"
---

## Your Connection Details

Before you begin, gather the following information from your server setup. You will need these for every client:

| Setting | Value |
|---|---|
| **Server Address** | Your domain name (e.g., `proxy.example.com`) |
| **Server Port** | `443` |
| **Password** | The password you set during server deployment |
| **Encryption Method** | `aes-256-gcm` |
| **Plugin** | `v2ray-plugin` |
| **Plugin Options** | `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0` |

{{< alert type="info" >}}
Replace `YOUR_DOMAIN` in the plugin options with your actual domain name. All other values should be entered exactly as shown.
{{< /alert >}}

---

## Platform Setup

Choose your platform below for step-by-step instructions:

{{< tabs names="Windows,macOS,Linux,Android,iOS" >}}

{{< tab index="0" >}}
### Windows

**1. Download the software**

You need two files:
- **Shadowsocks for Windows** -- Download the latest release from [github.com/shadowsocks/shadowsocks-windows/releases](https://github.com/shadowsocks/shadowsocks-windows/releases). Get the `Shadowsocks-x.x.x.zip` file.
- **v2ray-plugin** -- Download the Windows version from [github.com/shadowsocks/v2ray-plugin/releases](https://github.com/shadowsocks/v2ray-plugin/releases). Get the `v2ray-plugin-windows-amd64-vx.x.x.tar.gz` file.

**2. Set up the files**

1. Extract the Shadowsocks ZIP to a folder (e.g., `C:\Shadowsocks\`)
2. Extract `v2ray-plugin.exe` from the v2ray-plugin archive
3. Place `v2ray-plugin.exe` in the **same folder** as `Shadowsocks.exe`

**3. Configure the client**

1. Run `Shadowsocks.exe` -- a new icon will appear in your system tray (bottom-right corner)
2. Right-click the Shadowsocks tray icon and select **Edit Servers**
3. Fill in the fields:
   - **Server Addr:** `YOUR_DOMAIN`
   - **Server Port:** `443`
   - **Password:** your password
   - **Encryption:** `aes-256-gcm`
   - **Plugin Program:** `v2ray-plugin`
   - **Plugin Options:** `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
4. Click **Apply** then **OK**

**4. Enable the proxy**

Right-click the Shadowsocks tray icon and select **System Proxy** &rarr; **Global** to route all traffic through Shadowsocks.

Alternatively, choose **PAC** mode to only route traffic for blocked sites (uses a built-in list of commonly blocked domains).
{{< /tab >}}

{{< tab index="1" >}}
### macOS

**1. Download the software**

- **ShadowsocksX-NG** -- Download from [github.com/shadowsocks/ShadowsocksX-NG/releases](https://github.com/shadowsocks/ShadowsocksX-NG/releases). Get the `.dmg` file.
- **v2ray-plugin** -- Download the macOS version from [github.com/shadowsocks/v2ray-plugin/releases](https://github.com/shadowsocks/v2ray-plugin/releases). Get the `v2ray-plugin-darwin-amd64-vx.x.x.tar.gz` file (or `arm64` if you have an M-series Mac).

**2. Install v2ray-plugin**

Extract the plugin and move it to a system path:

```
tar xzf v2ray-plugin-darwin-*.tar.gz
sudo cp v2ray-plugin /usr/local/bin/
sudo chmod +x /usr/local/bin/v2ray-plugin
```

**3. Configure the client**

1. Open `ShadowsocksX-NG.dmg` and drag the app to your Applications folder
2. Launch ShadowsocksX-NG -- it will appear in your menu bar
3. Click the paper plane icon in the menu bar and select **Server Preferences**
4. Click the **+** button to add a new server
5. Fill in the fields:
   - **Address:** `YOUR_DOMAIN`
   - **Port:** `443`
   - **Password:** your password
   - **Encryption:** `aes-256-gcm`
   - **Plugin:** `v2ray-plugin`
   - **Plugin Options:** `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
6. Click **OK**

**4. Enable the proxy**

Click the ShadowsocksX-NG menu bar icon and select **Turn Shadowsocks On**. Choose **Global Mode** to route all traffic, or **PAC Mode** for selective routing.
{{< /tab >}}

{{< tab index="2" >}}
### Linux

**1. Install shadowsocks-libev and v2ray-plugin**

On Ubuntu or Debian:

```
sudo apt update
sudo apt install -y shadowsocks-libev
```

Download v2ray-plugin:

```
wget https://github.com/shadowsocks/v2ray-plugin/releases/latest/download/v2ray-plugin-linux-amd64-v1.3.2.tar.gz
tar xzf v2ray-plugin-linux-amd64-*.tar.gz
sudo mv v2ray-plugin /usr/local/bin/
sudo chmod +x /usr/local/bin/v2ray-plugin
```

**2. Create the client configuration**

Create the config file:

```
sudo nano /etc/shadowsocks-libev/client.json
```

Paste the following (replace the placeholder values):

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

**3. Start the client**

Run the Shadowsocks local proxy:

```
ss-local -c /etc/shadowsocks-libev/client.json
```

To run it in the background as a service:

```
sudo systemctl start shadowsocks-libev-local@client
sudo systemctl enable shadowsocks-libev-local@client
```

**4. Configure your applications**

The local SOCKS5 proxy is now available at `127.0.0.1:1080`. Configure your browser or system to use it:

- **Firefox:** Settings &rarr; Network Settings &rarr; Manual proxy &rarr; SOCKS Host: `127.0.0.1`, Port: `1080`, SOCKS v5
- **System-wide:** Set the environment variables `ALL_PROXY=socks5://127.0.0.1:1080` or use `proxychains`
{{< /tab >}}

{{< tab index="3" >}}
### Android

**1. Install the apps**

Install both apps from the Google Play Store:
- **[Shadowsocks](https://play.google.com/store/apps/details?id=com.github.shadowsocks)** -- The official Shadowsocks client
- **[v2ray Plugin](https://play.google.com/store/apps/details?id=com.github.nicecoolwind.shadowsocksr.v2ray.plugin)** -- The v2ray-plugin for Android

If the Play Store is not available in your country, you can download the APK files from [github.com/shadowsocks/shadowsocks-android/releases](https://github.com/shadowsocks/shadowsocks-android/releases).

**2. Configure the client**

1. Open the Shadowsocks app
2. Tap the **+** button to add a new profile
3. Select **Manual Settings** and fill in:
   - **Profile Name:** any name you like (e.g., "My Proxy")
   - **Server:** `YOUR_DOMAIN`
   - **Remote Port:** `443`
   - **Password:** your password
   - **Encrypt Method:** `aes-256-gcm`
   - **Plugin:** select `v2ray`
   - **Configure:** `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
4. Tap the check mark to save

**3. Connect**

Tap the profile you just created, then tap the paper plane icon to connect. Android will ask you to allow a VPN connection -- this is normal; Shadowsocks uses Android's VPN API to route traffic.
{{< /tab >}}

{{< tab index="4" >}}
### iOS

Due to Apple's App Store restrictions, there are no free Shadowsocks clients with v2ray-plugin support for iOS. The recommended options are:

**Option 1: Shadowrocket ($2.99)**

[Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) is the most popular and reliable option.

1. Purchase and install Shadowrocket from the App Store
2. Open the app and tap **+** to add a server
3. Select **Type: Shadowsocks**
4. Fill in the fields:
   - **Address:** `YOUR_DOMAIN`
   - **Port:** `443`
   - **Password:** your password
   - **Algorithm:** `aes-256-gcm`
   - **Obfs:** select `websocket`
   - **Obfs Host:** `YOUR_DOMAIN`
   - **Obfs Path:** `/shadowsocks`
   - **Enable TLS:** ON
5. Tap **Done** and then tap the toggle to connect

**Option 2: Potatso Lite (Free)**

[Potatso Lite](https://apps.apple.com/app/potatso-lite/id1239860606) is a free alternative, though it may not support all v2ray-plugin features.

1. Install Potatso Lite from the App Store
2. Tap **Add** &rarr; **Manual Input**
3. Select **Shadowsocks** and fill in your server details
4. For plugin settings, enter: `v2ray-plugin;tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
5. Save and connect

{{< alert type="info" >}}
If Shadowrocket is not available in your country's App Store, you may need to create an Apple ID in a different region (such as the US App Store) to purchase it.
{{< /alert >}}
{{< /tab >}}

{{< /tabs >}}

---

## Verify Your Connection

After connecting on any platform, run these three checks to make sure everything is working correctly:

### 1. Check your IP address

Visit [whatismyipaddress.com](https://whatismyipaddress.com). You should see your **server's IP address** (for a VPS) or your **home IP address** (for a Raspberry Pi), not the IP address of the network you are currently connected to.

### 2. DNS leak test

Visit [dnsleaktest.com](https://dnsleaktest.com) and click **Extended Test**. The results should show DNS servers associated with your Shadowsocks server's location, not your current ISP. If you see your ISP's DNS servers, your DNS is leaking and you may need to configure your client to proxy DNS queries as well.

### 3. Speed test

Visit [speedtest.net](https://speedtest.net) and run a test. You should see speeds within about 10% of your normal internet speed. If the speed is significantly slower:

- Try connecting to a Shadowsocks server closer to your physical location
- If using a Raspberry Pi, make sure it is connected via Ethernet
- Check that your VPS or home internet connection is not the bottleneck

---

## Troubleshooting

### Connection times out

- Verify your server is running: SSH into the server and run `docker ps`
- Check that the password, encryption method, and plugin options match exactly between client and server
- Make sure port 443 is open on the server's firewall

### Connected but no internet access

- Check your server's internet connectivity: SSH in and run `curl https://example.com`
- On Linux, make sure your application is configured to use the SOCKS5 proxy at `127.0.0.1:1080`
- On Windows/macOS, try switching between Global and PAC proxy modes

### Plugin errors

- Make sure v2ray-plugin is installed and accessible (in the same folder as Shadowsocks on Windows, or in `/usr/local/bin/` on macOS/Linux)
- Verify the plugin options string is exactly: `tls;host=YOUR_DOMAIN;path=/shadowsocks;mux=0`
- Check that your domain's SSL certificate is valid by visiting `https://YOUR_DOMAIN` in a browser

### Slow performance

- Choose a server location geographically closer to you
- Test your server's raw speed by running a speed test directly on the server: `curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -`
- If using a Raspberry Pi, check the Pi's CPU usage: `top`
