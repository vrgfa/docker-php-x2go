#!/bin/sh

# Create ssh "client" key
# http://stackoverflow.com/a/20977657

if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# generate fresh rsa key
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	# generate fresh dsa key
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi

USER_HOME=/home/docker

KEYGEN=/usr/bin/ssh-keygen
KEYFILE=${USER_HOME}/.ssh/id_rsa

if [ ! -f $KEYFILE ]; then
    $KEYGEN -q -t rsa -N "" -f $KEYFILE
    cat $KEYFILE.pub >> ${USER_HOME}/.ssh/authorized_keys
fi

if [ ! -z $SSH_PASSWORD ]; then
     echo docker:$SSH_PASSWORD | chpasswd
     echo "Your ssh credentials: user:docker, passwd: $SSH_PASSWORD"
fi

echo "== Use this private key to log in =="
cat $KEYFILE

# Start sshd
/usr/sbin/sshd -D
