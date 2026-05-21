FROM alpine:3.23.4

# Add Liara mirrors (if not in iran, comment them)
RUN ALPINE_VERSION=$(cat /etc/alpine-release | cut -d'.' -f1-2) && \
	echo "https://linux-mirror.liara.ir/repository/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
	echo "https://linux-mirror.liara.ir/repository/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories

# Add IUT mirrors (if not in iran, comment them)
# RUN ALPINE_VERSION=$(cat /etc/alpine-release | cut -d'.' -f1-2) && \
	#echo "http://repo.iut.ac.ir/repo/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
	#echo "http://repo.iut.ac.ir/repo/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories

# Install necessary packages: OpenSSH for SSH server, openssh-client for SSH commands, and shadow for user management.
RUN apk update && apk add --no-cache openssh-server shadow

# Create the 'gitlab-runner' user and group
RUN adduser -s /bin/sh -D gitlab-runner

# Create the ssh config directory for the gitlab-runner user
RUN mkdir -p /home/gitlab-runner/.ssh && \
    chown -R gitlab-runner:gitlab-runner /home/gitlab-runner/.ssh

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
