# Initial setting
bash <(curl -s http://saturn.5fpro.com/ubuntu/init.sh)

# Add user
bash <(curl -s http://saturn.5fpro.com/ubuntu/adduser.sh)

# Install AWS-cli
bash <(curl -s http://saturn.5fpro.com/ubuntu/aws-cli.sh)

# Force command prompt with color
bash <(curl -s http://saturn.5fpro.com/ubuntu/sh-color.sh)

# Setup hostname and login banner
bash <(curl -s http://saturn.5fpro.com/ubuntu/hostname.sh)
