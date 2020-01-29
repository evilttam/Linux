#!/bin/sh
COMP=$(hostname)
SUBJ="IP address for $COMP"
EMAIL="ematts123@gmail.com"
WD=$(pwd)
FILE="${WD}/ip.txt"
ip1=""
ip2=""
ip3=""

# check for and install msmtp if it is not installed
dpkg -s msmtp 2>/dev/null >/dev/null || sudo apt-get -y install msmtp

if test -f "$FILE"; then
echo $FILE exists
else
> $FILE
fi


if [[ $(crontab -l | egrep -v "^(#|$)" | grep -q '/home/pi/Documents/ipaddress.sh'; echo $?) == 1 ]]; then
echo "crontab exists"
else
(crontab -l 2>/dev/null; echo "0 0 * * * /home/pi/Documents/ipaddress.sh") | crontab - &&
(crontab -l 2>/dev/null; echo "@reboot sleep 60 && /home/pi/Documents/ipaddress.sh") | crontab -
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
