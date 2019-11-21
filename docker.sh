#cloud-config
users:
  - default
  - name: verizon
    passwd: $6$/fIMAFecJn1max80$tWtOqbFYcNge8vchkkVJgd95BJLZ196sMM59ARW2mtaDyqpTLczyCdGcPFGhVnVODxmppu9YaVY5lDGPx1rhU0
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkYNOYhJxmQOStVeuRWvpihamy0i0q9zdP+TwB3civJrKqriAc5uJEQwahD/Fc2fKBMscy7d/+lWDLOdrRGfVdL1wV0+OCHohbfpBezZBAFOCmeDhl3LAcYVwA5Fxy28TwkNu90gJYhEoNPnjHQxtpi4uA/miXuM+mvmI53R48zA+n3BdnfbVucSBbrLqKM0Ehyc8USdHh5rxyP8mesFMyJcrYKXylLPel2P5vvlFDeyu8LeyPbwYd0ES3xB07pCwKu9JyCjtkUxmqyeF/z5LkWNfQQAXRQsX1qfmXkH3npK4yMVJfkFSLbbhtYJF7DwVOx+vF9TzBrYnxlC8xWOHX

ssh_pwauth: yes

password: $6$/fIMAFecJn1max80$tWtOqbFYcNge8vchkkVJgd95BJLZ196sMM59ARW2mtaDyqpTLczyCdGcPFGhVnVODxmppu9YaVY5lDGPx1rhU0

chpasswd:
  expire: False
  list:
    - root:$6$/fIMAFecJn1max80$tWtOqbFYcNge8vchkkVJgd95BJLZ196sMM59ARW2mtaDyqpTLczyCdGcPFGhVnVODxmppu9YaVY5lDGPx1rhU0

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

      usermod -a -G docker verizon

      mkdir /opt/docker
      chown verizon. /opt/docker
    path: /root/docker-setup.sh
    permissions: '0700'
