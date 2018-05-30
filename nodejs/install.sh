echo "Installed user? (apps)"
read SU_USER
if [ "$SU_USER" == "" ]; then SU_USER="apps"; fi;

echo "To see current nvm version: https://github.com/creationix/nvm#install-script"
echo "nvm version? (0.33.0)"
read NVM_VER
if [ "$NVM_VER" == "" ]; then NVM_VER="0.33.0"; fi;

echo "To see current node.js version: https://nodejs.org/"
echo "nodejs version? (v6.9.5)"
read NODE_VER
if [ "$NODE_VER" == "" ]; then NODE_VER="v6.9.5"; fi;

apt-get update
apt-get upgrade -y

install_url="https://raw.githubusercontent.com/creationix/nvm/v${NVM_VER}/install.sh"
CMD="cd /home/${SU_USER} && (curl -o- ${install_url} | bash)"
sudo -i -u $SU_USER bash -c "$CMD"

nvmsh=". \"/home/${SU_USER}/.nvm/nvm.sh\""
CMD="${nvmsh} && nvm install ${NODE_VER}"
sudo -i -u $SU_USER bash -c "$CMD"

echo "Linking node to /usr/bin/node ..."
nodebin=`sudo -i -u $SU_USER bash -c "${nvmsh} && which node"`
ln -s $nodebin /usr/bin/node

CMD="echo \"EXECJS_RUNTIME=Node\" >> /home/${SU_USER}/.bashrc"
sudo -i -u $SU_USER bash -c "$CMD"
