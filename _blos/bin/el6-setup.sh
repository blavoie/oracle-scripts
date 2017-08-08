#!/bin/bash

# Packages dependencies
yum -y install sysstat bc glibc libaio pam xorg-x11-utils gcc compat-libcap1 nfs-utils compat-libstdc++-33 bind-utils ksh smartmontools libgcc openssh-clients libaio-devel make libstdc++-devel binutils glibc-devel module-init-tools util-linux-ng initscripts gcc-c++ procps ethtool xorg-x11-xauth libstdc++

# Create groups and users
groupadd oinstall
groupadd dba
useradd -g oinstall -Gdba,vboxsf grid
useradd -g oinstall -Gdba,vboxsf oracle
passwd grid
passwd oracle

# Kernel Parameters
cat >> /etc/sysctl.conf << DELIM

# Oracle Software Kernel Settings
fs.file-max = 6815744
kernel.sem = 250 32000 100 128
kernel.shmmni = 4096
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500
DELIM

sysctl -p

# Change user limits for oracle & grid users 
cat >> /etc/security/limits.conf << DELIM

# Oracle Software Session Limits
oracle           soft    nproc     2047
oracle           hard    nproc    16384
oracle           soft    nofile    1024
oracle           hard    nofile   65536
oracle           soft    stack    10240
oracle           hard    stack    32768
grid             soft    nproc     2047
grid             hard    nproc    16384
grid             soft    nofile    1024
grid             hard    nofile   65536
grid             soft    stack    10240
grid             hard    stack    32768
DELIM

# Create directories
mkdir -p /u01/app/grid
mkdir -p /u01/app/oracle
chown -R grid:oinstall /u01
chown oracle:oinstall /u01/app/oracle
chmod -R 775 /u01/
