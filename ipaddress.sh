#!/bin/sh
COMP=$(hostname)
SUBJ="IP address for $COMP"
EMAIL="ematts123@gmail.com"
WD=$(pwd)
FILE="${WD}/ip.txt"
ip1=""
ip2=""
ip3=""
cronjobfile="/home/pi/Documents/cronjob"
rootcron="/var/spool/cron/crontabs/root"
# check for and install msmtp if it is not installed
dpkg -s msmtp 2>/dev/null >/dev/null || sudo apt-get -y install msmtp

if test -f "$FILE"; then
echo $FILE exists
else
> $FILE
fi

rm $cronjobfile
> $cronjobfile
if test -f "$rootcron"; then
echo $rootcron exists
else 
> $rootcron
fi
crontab -l -u root >> $cronjobfile
if grep "no crontab for root" $cronjobfile; then
echo "Cronjob exists"
fi

if grep -i "/home/pi/Documents/ipaddress.sh" $rootcron; then
echo "$rootcron contains /home/pi/Documents/ipaddress.sh"
else
echo "0 0 * * * /home/pi/Documents/ipaddress.sh" >> $rootcron \n
echo "@reboot sleep 60 && /home/pi/Documents/ipaddress.sh" >> $rootcron \n
fi


if test -f "/etc/msmtprc"; then
echo "/etc/msmtprc is in proper location"
else
cp msmtprc /etc
fi

read ip1 < $FILE
ip2=$(wget -qO- ifconfig.me/ip)
ip3=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
ip4=$(ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
if [ "$ip1" = "$ip2" ]
then
  exit
else
  echo "To: matthew.jones12@gmail.com" > $FILE
  echo "From: NoReply@noreply.com" >> $FILE
  echo "Subject: $SUBJ" >> $FILE
  echo "Date/Time  -	`date '+%F_%H.%M.%S'`">> $FILE
  echo "Public IP address  -	$ip2" >> $FILE
  echo "Wired IP address  -	$ip3" >> $FILE
  echo "Wireless IP address  -	$ip4" >> $FILE
  cat $FILE | msmtp -a default $EMAIL
 
  exit
fi
