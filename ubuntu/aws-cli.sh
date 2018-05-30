echo "user? [apps]"
read user
if [[ $user == "" ]]; then user="apps"; fi;

apt-get install python3.4 python3-dev -y

user_home="/home/${user}"
str_path='"$HOME/.local/bin:$PATH"'
shell="\
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
echo 'export PATH=$str_path' >> $user_home/.bashrc
source ~/.bashrc
~/.local/bin/pip install awscli --upgrade --user
~/.local/bin/aws configure
"
tmp_file="/tmp/aws-cli-install.sh"
echo "$shell" > $tmp_file
chmod +x $tmp_file
sudo -i -u $user bash -c $tmp_file
rm $tmp_file
