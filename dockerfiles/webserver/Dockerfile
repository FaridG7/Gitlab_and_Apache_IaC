FROM httpd:2.4.67-alpine

# Add IUT mirrors if you're Iranian (uncomment if you're not)
RUN ALPINE_VERSION=$(cat /etc/alpine-release | cut -d'.' -f1-2) && \
  echo "https://linux-mirror.liara.ir/repository/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
  echo "https://linux-mirror.liara.ir/repository/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories
 

# Install and run the ssh daemon
RUN apk update && apk add --no-cache openssh-server

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Add a user for deployment
RUN adduser -D -s /bin/sh deployer && \
  addgroup deployer www-data && \
  mkdir -p /home/deployer/.ssh && \
  chmod 700 /home/deployer/.ssh && \
  chown deployer:deployer /home/deployer/.ssh

EXPOSE 22
CMD ["/entrypoint.sh", "httpd-foreground"]
