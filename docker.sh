#cloud-config
users:
  - default
  - name: andylab
    passwd: 
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa 
ssh_pwauth: yes

password: 

chpasswd:
  expire: False
  list:
    - root:
write_files:
  - content: |
      #!/usr/bin/env bash

      set -x

      echo "proxy=http://localhost:53128" >> /etc/yum.conf

      yum -y check-update
      yum -y upgrade
      yum -y install yum-utils device-mapper-persistent-data lvm2 traceroute openldap-clients nss-pam-ldapd epel-release
      yum -y install python36 python36-pip

      yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      yum -y install docker-ce docker-ce-cli containerd.io

      mkdir /etc/docker
      echo -e '{\n        "userns-remap": "default"\n}' > /etc/docker/daemon.json

      echo "dockremap:100000:65536" >> /etc/subuid
      echo "dockremap:100000:65536" >> /etc/subgid

      ns=$(sysctl user.max_pid_namespaces | sed -e 's/pid/user/')
      echo ${ns} > /etc/sysctl.d/00-docker.conf
      sysctl -w $(echo ${ns} | sed -e 's/[[:space:]]*//g')

      systemctl start docker
      systemctl enable docker

      export http_proxy=http://localhost:53128; export https_proxy=${http_proxy}

      pip3 install --upgrade pip
      pip  install docker dumper pyyaml

      usermod -a -G docker andylab

      mkdir /opt/docker
      chown andylab. /opt/docker
    path: /root/docker-setup.sh
    permissions: '0700'
