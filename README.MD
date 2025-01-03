## OpenVPN server on docker

With this repo, you can easily run OpenVPN server on docker.

It uses latest alpine linux.

Thanks to `kylemanna` for `https://github.com/kylemanna/docker-openvpn`, as I have used code fragments from this repo.
But I think it has too many features and is little complicated. So, I built my own image.

You will need to generate OpenVPN key/crt files on other system and then use them in docker.

Here you can easily generate your keys on both windows and
linux: `https://community.openvpn.net/openvpn/wiki/EasyRSA3-OpenVPN-Howto`

You can use [peer-fingerprint](https://github.com/OpenVPN/openvpn/blob/master/doc/man-sections/example-fingerprint.rst) method for simple openvpn server 

## Running container

You need to include run.sh in `/data` directory with all needed files and add volume of that folder. Please note that
openvpn config file is called `server.conf` so be sure to name config file as needed.

To test service:

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

For production:

```
services:
  openvpn-server:
    image: kostamilorava/openvpn-server
    container_name: openvpn-server
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    sysctls:
      net.ipv6.conf.all.disable_ipv6: "0"
      net.ipv6.conf.default.forwarding: "1"
      net.ipv6.conf.all.forwarding: "1"
      net.ipv4.ip_forward: "1"
    volumes:
      - /path/to/local/folder:/data
    ports:
      - "1194:1194/udp"
    devices:
      - /dev/net/tun
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
