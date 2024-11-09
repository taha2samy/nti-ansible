# Use the official Ubuntu image as the base image
FROM ubuntu:latest

# Set environment variable to non-interactive to avoid installation prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install openssh-server
RUN apt-get update && \
    apt-get install -y openssh-server sudo && \
    mkdir /var/run/sshd

# Set a root password for SSH access (optional)
RUN echo 'root:root' | chpasswd

# Create the .ssh directory for the root user and set proper permissions
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Copy the SSH public key into the authorized_keys file for root
COPY id_rsa.pub /root/.ssh/authorized_keys

# Set proper permissions for the authorized_keys file
RUN chmod 600 /root/.ssh/authorized_keys

# Create the new user (nti) and add to sudo group (optional, if needed)
RUN useradd -m -s /bin/bash nti && \
    echo 'nti:nti' | chpasswd && \
    usermod -aG sudo nti

# Create the .ssh directory for the new user and set proper permissions
RUN mkdir -p /home/nti/.ssh && chmod 700 /home/nti/.ssh

# Copy the SSH public key into the authorized_keys file for the new user
COPY id_rsa.pub /home/nti/.ssh/authorized_keys

# Set proper permissions for the authorized_keys file
RUN chmod 600 /home/nti/.ssh/authorized_keys

# Set proper permissions for the home directory
RUN chown -R nti:nti /home/nti

# Copy the custom sshd_config file into the container
COPY sshd_config /etc/ssh/sshd_config

# Expose SSH port
EXPOSE 22

# Start SSH service when the container runs
CMD ["/usr/sbin/sshd", "-D"]
