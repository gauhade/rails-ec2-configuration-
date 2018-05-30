echo "Who to install? (apps)"
read WHO
if [ "$WHO" == "" ]; then WHO="apps"; fi;

echo "Ruby version?"
read RUBY_VERSION

echo "remove rvm? (Y/n)"
read remove_rvm

bash_file=".bashrc"

if [[ $remove_rvm != 'n' ]]; then
  rvm implode
fi;

apt-get update
apt-get upgrade -y
apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev

user_home="/home/${WHO}"
shell="\
cd ${user_home}
git clone git://github.com/sstephenson/rbenv.git .rbenv
echo 'export PATH=\"\$HOME/.rbenv/bin:\$PATH\"' >> ${user_home}/${bash_file}
echo 'eval \"\$(rbenv init -)\"' >> ${user_home}/${bash_file}
git clone git://github.com/sstephenson/ruby-build.git ${user_home}/.rbenv/plugins/ruby-build
echo 'export PATH=\"\$HOME/.rbenv/plugins/ruby-build/bin:\$PATH\"' >> ${user_home}/${bash_file}
. ~/${bash_file}
${user_home}/.rbenv/bin/rbenv install -v ${RUBY_VERSION}
${user_home}/.rbenv/bin/rbenv global ${RUBY_VERSION}
echo \"gem: --no-document\" > ${user_home}/.gemrc
${user_home}/.rbenv/shims/gem install bundler
${user_home}/.rbenv/bin/rbenv rehash
"
echo "$shell" > /tmp/rbenv-install.sh
chmod +x /tmp/rbenv-install.sh
sudo -i -u $WHO bash -c "/tmp/rbenv-install.sh"
rm /tmp/rbenv-install.sh
