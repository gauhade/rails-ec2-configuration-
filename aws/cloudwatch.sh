cd /root
apt-get update
apt-get install unzip -y
apt-get install libwww-perl libdatetime-perl -y
curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip -O
unzip CloudWatchMonitoringScripts-1.2.2.zip
rm CloudWatchMonitoringScripts-1.2.2.zip
cd aws-scripts-mon

echo "Please make sure your IAM role has following permissions:cloudwatch:PutMetricData
- cloudwatch:GetMetricStatistics
- cloudwatch:ListMetrics
- cloudwatch:PutMetricData
- ec2:DescribeTags

ref IAM policy:
{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
        {
            \"Sid\": \"Stmt1483448372000\",
            \"Effect\": \"Allow\",
            \"Action\": [
                \"cloudwatch:GetMetricStatistics\",
                \"cloudwatch:ListMetrics\",
                \"cloudwatch:PutMetricData\"
            ],
            \"Resource\": [
                \"*\"
            ]
        },
        {
            \"Sid\": \"Stmt1483448479000\",
            \"Effect\": \"Allow\",
            \"Action\": [
                \"ec2:DescribeTags\"
            ],
            \"Resource\": [
                \"*\"
            ]
        }
    ]
}
"
echo "press ENTER to contiune"
read temp

echo "AWS access key:"
read AWS_ACCESS_KEY
echo "AWS secret key:"
read AWS_SECRET_KEY

CONFIG_FILE="/root/aws-scripts-mon/awscreds.template"
sed -i "s@AWSAccessKeyId=@AWSAccessKeyId=${AWS_ACCESS_KEY}@" $CONFIG_FILE
sed -i "s@AWSSecretKey=@AWSSecretKey=${AWS_SECRET_KEY}@" $CONFIG_FILE

echo "*/1 * * * * root /root/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util --disk-path=/ --from-cron" > /etc/cron.d/aws-scripts-mon
chmod 0600 /etc/cron.d/aws-scripts-mon
service cron restart

echo "set cache clearing after reboot"
clear_sh="rm -rf /var/tmp/aws-mon"
if grep -q "${clear_sh}" "/etc/rc.local"; then echo "already appened"; else sed -i -e '$i '"$clear_sh"'\n' /etc/rc.local; fi;
echo "testing..."
~/aws-scripts-mon/mon-put-instance-data.pl --mem-util --verify --verbose
~/aws-scripts-mon/mon-get-instance-stats.pl --recent-hours=1
~/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util --disk-path=/ --from-cron
echo "done!"
