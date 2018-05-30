file="/etc/monit/monitrc"
if [ -f "$file" ]
then
  echo 'detected monit installed...'
else
  read -p "monit not install, press ENTER to install or ^C to cancel" ans
  curl -o /tmp/install-monit.sh http://saturn.5fpro.com/monit/install.sh
  chmod +x /tmp/install-monit.sh
  /tmp/install-monit.sh
  rm /tmp/install-monit.sh
fi

read -p "setup nginx? (y/N)" ans
if [[ ($ans == "y") || ($ans == "Y") ]]; then
  curl -o /tmp/nginx.sh http://saturn.5fpro.com/monit/nginx.sh
  chmod +x /tmp/nginx.sh
  /tmp/nginx.sh
  rm /tmp/nginx.sh
fi;

read -p "setup unicorn? (y/N)" ans
if [[ ($ans == "y") || ($ans == "Y") ]]; then
  curl -o /tmp/unicorn.sh http://saturn.5fpro.com/monit/unicorn.sh
  chmod +x /tmp/unicorn.sh
  /tmp/unicorn.sh
  rm /tmp/unicorn.sh
fi;

read -p "setup sidekiq? (y/N)" ans
if [[ ($ans == "y") || ($ans == "Y") ]]; then
  curl -o /tmp/sidekiq.sh http://saturn.5fpro.com/monit/sidekiq.sh
  chmod +x /tmp/sidekiq.sh
  /tmp/sidekiq.sh
  rm /tmp/sidekiq.sh
fi;
