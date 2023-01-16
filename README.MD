## OpenVPN server on docker

With this repo, you can easily run OpenVPN server on docker.

It uses latest (for now) alpine linux.

Thanks to `kylemanna` for `https://github.com/kylemanna/docker-openvpn`, as I have used code fragments from this repo.
But I think it has too many features and is little complicated. So, I built my own image.

You will need to generate OpenVPN key/crt files on other system and then use them in docker.

Here you can easily generate your keys on both windows and
linux: `https://community.openvpn.net/openvpn/wiki/EasyRSA3-OpenVPN-Howto`

## Running container

You need to include run.sh in `/data` directory with all needed files and add volume of that folder. Please note that
openvpn config file is called `server.conf` so be sure to name config file as needed.

For testing (note --rm, will be deleted after container is killed)

```
docker run -v /path/to/local/folder/:/data/ \
 --rm -d -it -p 1194:1194/udp \
 --sysctl net.ipv6.conf.all.disable_ipv6=0 \
 --sysctl net.ipv6.conf.default.forwarding=1 \
 --sysctl net.ipv6.conf.all.forwarding=1 \
 --sysctl net.ipv4.ip_forward=1 \
 --cap-add=NET_ADMIN \
 --name test kostamilorava/openvpn-server
```

For running on real server:

```
docker run -v /path/to/local/folder/:/data/ \
 -d -p 1194:1194/udp \
 --sysctl net.ipv6.conf.all.disable_ipv6=0 \
 --sysctl net.ipv6.conf.default.forwarding=1 \
 --sysctl net.ipv6.conf.all.forwarding=1 \
 --sysctl net.ipv4.ip_forward=1 \
 --cap-add=NET_ADMIN \
 --restart unless-stopped \
 --name openvpn-server kostamilorava/openvpn-server
```

Docker repository url: `https://hub.docker.com/repository/docker/kostamilorava/openvpn-server`

## Connect more than 254 users to server

I had situation when I needed to connect more than 254 clients (with same certficate)

For this, set this in run.sh:

`OVPN_SERVER=10.1.0.0/0`

Also, don't forget to change this line in server.conf:

`server 10.1.0.0 255.255.0.0`

## Note!

This package was made for my personal usage. So if there is not enough information, do not judge me. Will be glad to
help you if something :)
