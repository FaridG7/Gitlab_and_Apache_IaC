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
RUN apk update && apk add --no-cache openssh-server shadow openssl rsync

# Generate the host keys
RUN ssh-keygen -A

# Create a random password
RUN openssl rand -base64 16 > /initial-root-password

# Change root's password
RUN echo "root:$(cat /initial-root-password)" | chpasswd

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
