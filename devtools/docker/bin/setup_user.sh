#!/bin/bash

username=${3:-devuser}
usergroup=${4:-devgroup}
if [ $1 -eq 0 ] || [[ $3 == "$root" ]]; then

  if ! [ -f /usr/local/bin/commit ]; then
    if [ -f /usr/local/bin/commit.sh ]; then
      ln -s /usr/local/bin/commit.sh /usr/local/bin/commit
      chmod +x /usr/local/bin/commit
    fi
  fi
  exit 0
fi
groupadd --non-unique -g $2 $usergroup
useradd -u $1 -g $usergroup -m $username

# some dirty work to make it work as well
cp /root/.bashrc /home/$username/
cp -r /root/.vim /home/$username/
cp /root/.vimrc /home/$username/
chown -R $username:$usergroup /home/$username/.vim* /home/$username/.bashrc
devlink=`readlink -f ~/dev`
gorootlink=`readlink -f ~/goroot`
chown -R $username:$usergroup $devlink
ln -s $devlink /home/$username/dev 
ln -s $gorootlink /home/$username/goroot
chown -R $username:$usergroup /home/$username/dev
chown -R $username:$usergroup /home/$username/goroot

# prepare sudoers
chown -R $username:$usergroup /home/$username/dev
sed -i '/%sudo/s/ALL$/NOPASSWD:ALL/' /etc/sudoers
gpasswd -a $username docker
gpasswd -a $username sudo

if ! [ -f /usr/local/bin/commit ]; then
  if [ -f /usr/local/bin/commit.sh ]; then
    ln -s /usr/local/bin/commit.sh /usr/local/bin/commit
    chmod +x /usr/local/bin/commit
  fi
fi
commit
