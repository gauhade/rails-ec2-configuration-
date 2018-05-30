SH_COLOR_FILE=$1
if [[ $SH_COLOR_FILE == "" ]]; then
  echo "Target appended file (may .bashrc)?"
  read SH_COLOR_FILE
fi;
SH_COLOR=`curl http://saturn.5fpro.com/ubuntu/sh-color.setting`
echo "$SH_COLOR" >> $SH_COLOR_FILE
