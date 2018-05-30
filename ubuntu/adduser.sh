echo "user? [apps]"
read user
if [[ $user == "" ]]; then user="apps"; fi;
echo "Public key for ssh? (ENTER to skip)"
read public_key
echo "Install rbenv?[y/N]"
read rbenv
echo "Install nodejs?[y/N]"
read nodejs
echo "Install AWS-cli?[y/N]"
read awscli

if [ -f "/home/${user}/.bashrc" ]; then
  echo "User ${user} exists"
else
  adduser --disabled-password --gecos "" $user
fi;

if [[ $public_key != "" ]]; then
  target_file="/home/${user}/.ssh/authorized_keys"
  mkdir /home/$user/.ssh
  chown 0700 /home/$user/.ssh
  echo $public_key >> $target_file
  chmod 0600 $target_file
  chown -R $user:$user /home/$user/.ssh
fi;

SH_COLOR_FILE="/home/${user}/.bashrc"
curl http://saturn.5fpro.com/ubuntu/sh-color.sh|bash -s $SH_COLOR_FILE
chown $user:$user $SH_COLOR_FILE

if [[ $rbenv == 'y' ]]; then
  bash <(curl -s http://saturn.5fpro.com/rbenv/install.sh)
fi;

if [[ $nodejs == 'y' ]]; then
  bash <(curl -s http://saturn.5fpro.com/nodejs/install.sh)
fi;

if [[ $awscli == 'y' ]]; then
  bash <(curl -s http://saturn.5fpro.com/ubuntu/aws-cli.sh)
fi;
