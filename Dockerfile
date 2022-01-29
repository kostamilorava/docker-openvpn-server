# Use alpine os, smallest image
FROM alpine:latest

LABEL maintainer="Kosta Milorava <kosta.milorava@gmail.com>"

#For pamtester package, add also testing repo. If not needed, ignore it
#echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
RUN apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator libqrencode && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

RUN chmod a+x /usr/local/bin/*

CMD ["./data/run.sh"]