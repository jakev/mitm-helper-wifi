# Wifi Man-in-the-Middle Helper

## About
These scripts are designed to make it easy and straight-forward to configure a Ubuntu virtual machine to act as a WiFi access point (AP), and forward traffic to your favorite web proxy or other tool. I personally use this for doing mobile and other embedded device testing. If you've used my PPTP helper, you should feel right at home configuring and using this tool!

*Note: There is no black magic here - simply some utilities to make it easier to use.*

The typical work flow would be a VM that has one wired (or could even be wireless) interface, we'll call it 'eth0', and a USB WiFi dongle. `mitm-wifi` will generate a `hostapd` configuration file, create a WiFi access point from the USB WiFi dongle, and then apply appropriate `iptables` rules so that you can intercept and modify traffic as you please.

## Configuration
### Tool Setup
This tool is designed to work on Ubuntu virtual machines operating in 'bridged' mode. Your mileage will vary if you use another VM, but I suppose Kali Linux should also work fine.

To download and setup the tool, run the following commands:

    $ git clone https://github.com/jakev/mitm-helper-wifi
    $ cd mitm-helper-wifi
    $ sudo ./install_dependencies.sh
    $ sudo dpkg -i build/mitm-helper-wifi_0.1.deb

### Global Settings
I tried to make configuration of the tool both straightforward and flexible. I use a TP Link TL-WN722N, that cost me about 12 dollars on Amazon and does everything I need. If you use a similiar adapter, your setup should work completely out of the box.

The configuration file can be found at `/etc/mitm-wifi.conf`. The only setting you _need_ to specify is a WPA passphrase, but you can also select a custom SSID in the section 'Global':

```
[Global]
Ssid=CoolNetwork
Key=M0bileisfuN
```

What does this do? This configures a 802.11g network on channel 1, using WPA2 PSK/CCMP. If this doesn't work for you, check out the next section on overriding.

### hostapd Overriding
If for some reason the `hostapd` configuration I'm using by default doesnt fit your setup, powerusers can manually override any `hostapd` configuration settings. You're own your own for validation here, and you might not be able to achieve exactly what you'd like.

As an example, let's say that channel 1 is not ideal and you'd rather use 10.  We can override these parameters in the `/etc/mitm-wifi.conf` file by specifying the exact `hostapd` config equivalent to overrider

```
[Global]
Ssid=CoolNetwork
Key=M0bileisfuN

[Override]
channel=10
```

If you need more control than this, please message me and we can talk about adding additional features.

### Configuring Proxy Rules
We'll also add sections to the `/etc/mitm-wifi.conf` file to configure how you will intercept traffic. By default, traffic is simply passed through (no proxy). This should work if you just want to observe traffic using a tool like Wireshark. In our case, let's assume we have Burp running on port 9999, and we'd like to forward traffic on ports 80 and 443 to this proxy. We configure the `/etc/mitm-wifi.conf` file as follows:

```
...

[HTTP Proxies]
ProxyPort:9999
ForwardPorts:80,443
```

Now, let's say that we determine our app/device uses a custom protocol on port 1234, and Burp is not useful for intercepting this traffic. We created a python script, and it is listening on port 8888. Let's add rules for this:

```
...

[HTTP Proxies]
ProxyPort:9999
ForwardPorts:80,443

[Binary Coolness Proxy]
ProxyPort:8888
ForwardPorts:1234
```

This configuration can be found in the file `sample.mitm-wifi.conf`. Note that the section names in the `mitm-wifi.conf` can be named anything except 'Global' and 'Override'.

*Side note for Burp users: You'll likely need to listen on all interfaces AND enable the invisible proxying to have your setup work properly.*

#### Starting the WiFi AP
Once you're ready to start, run:

    $ sudo mitm-wifi -v

If you want to specify a custom configuration file, you can do so with the `-c` argument:

    $ sudo mitm-wifi -v -c my-wifi.conf

By default, `hostapd` will attempt to find the USB dongle on wlan0, but if your adapter is named different, use the `-w` argument:

    $ sudo mitm-wifi -v -w ath1

### Stopping the WiFi AP
By hitting Ctrl+C, the script will begin the shutdown process.
