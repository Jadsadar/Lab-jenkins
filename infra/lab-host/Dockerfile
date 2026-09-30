# Stand-in for the EC2 instance Terraform creates in LocalStack (LocalStack's free EC2 is a mock
# with no real machine to SSH into). Ansible configures this container instead; the inventory
# still comes from `terraform output`. Build and run it with infra/lab-host/setup.ps1.
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
# The base image already ships an "ubuntu" user (uid 1000); it only needs sudo and an SSH key
RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server python3 sudo \
    && rm -rf /var/lib/apt/lists/* \
    && echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu \
    && mkdir -p /run/sshd /home/ubuntu/.ssh \
    && chown ubuntu:ubuntu /home/ubuntu/.ssh && chmod 700 /home/ubuntu/.ssh
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
