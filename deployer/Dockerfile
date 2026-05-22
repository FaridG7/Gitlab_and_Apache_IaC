ARG TAG
FROM alpine:${TAG}

# Add Liara mirrors (if not in iran, comment them)
RUN ALPINE_VERSION=$(cat /etc/alpine-release | cut -d'.' -f1-2) && \
	echo "https://linux-mirror.liara.ir/repository/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
	echo "https://linux-mirror.liara.ir/repository/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories

# Add IUT mirrors (if not in iran, comment them)
# RUN ALPINE_VERSION=$(cat /etc/alpine-release | cut -d'.' -f1-2) && \
	#echo "http://repo.iut.ac.ir/repo/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
	#echo "http://repo.iut.ac.ir/repo/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories

# Install necessary packages: OpenSSH for SSH server, openssh-client for SSH commands, and shadow for user management.
RUN apk update && apk add --no-cache openssh-server shadow openssl rsync

# Generate the host keys
RUN ssh-keygen -A

# Create a random password
RUN openssl rand -base64 16 > /gitlab-runner-passwd

# Create the 'gitlab-runner' user
RUN adduser -s /bin/sh -D gitlab-runner && echo "gitlab-runner:$(cat /gitlab-runner-passwd)" | chpasswd

# Create deployer group and add gitlab-runner user to it
RUN addgroup -g 2000 deployers && addgroup gitlab-runner deployers

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
