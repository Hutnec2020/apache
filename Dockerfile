FROM node:latest


ARG
    WEB_DOMAIN=web.65670678.gq \  
    ARGO_DOMAIN=apache.65670678.gq \
    ARGO_AUTH=eyJhIjoiZjYwMmM5OTYwYjI3OWYzZWQyM2MwYmZmZTNlMDExMTYiLCJ0IjoiZTg3YWM3NTItZDA5My00MTI3LTg2ZGMtNmEyYjg0MGY0OWNkIiwicyI6IllUY3hNRGxrWkdNdE1EaG1OeTAwTURObExUZzBOemN0WXpNNU1UUmtZV1l6T1RjeCJ9 \
    WEB_USERNAME=chou \
    WEB_PASSWORD=chou2023


WORKDIR /home/choreouser

COPY apache/* /home/choreouser/

RUN apt-get update &&\
    apt-get install -y iproute2 &&\
    wget -O tomcat.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb &&\
    dpkg -i tomcat.deb &&\
    rm -f tomcat.deb &&\
    addgroup --gid 10001 choreo &&\
    if echo "$ARGO_AUTH" | grep -q 'TunnelSecret'; then \
      echo "$ARGO_AUTH" | sed 's@{@{"@g;s@[,:]@"\0"@g;s@}@"}@g' > tunnel.json; \
      echo "tunnel: $(echo "$ARGO_AUTH" | grep -oP "(?<=TunnelID:).*(?=})") \n\
credentials-file: /home/choreouser/tunnel.json \n\
protocol: h2mux \n\
\n\
ingress: \n\
  - hostname: $ARGO_DOMAIN \n\
    service: http://localhost:8080 \n\
  - hostname: $WEB_DOMAIN \n\
    service: http://localhost:3000 \n\

    originRequest: \n\
      noTLSVerify: true \n\
  - service: http_status:404" > tunnel.yml; \
    else \
      ARGO_TOKEN=$ARGO_AUTH; \
      sed -i "s#ARGO_TOKEN_CHANGE#$ARGO_TOKEN#g" entrypoint.sh; \
    fi &&\


    sed -i "s#WEB_USERNAME_CHANGE#$WEB_USERNAME#g; s#WEB_PASSWORD_CHANGE#$WEB_PASSWORD#g" entrypoint.sh &&\
    sed -i "s#WEB_USERNAME_CHANGE#$WEB_USERNAME#g; s#WEB_PASSWORD_CHANGE#$WEB_PASSWORD#g; s#WEB_DOMAIN_CHANGE#$WEB_DOMAIN#g" server.js &&\
    adduser --disabled-password  --no-create-home --uid 10001 --ingroup choreo choreouser &&\
    usermod -aG sudo choreouser &&\
    chown -R 10001:10001 apache.js entrypoint.sh config.json &&\
    chmod +x apache.js entrypoint.sh nezha-agent ttyd &&\
    npm install -r package.json

ENTRYPOINT [ "node", "server.js" ]

USER 10001
