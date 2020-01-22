#!/bin/sh
COMP=$(hostname)
SUBJ="IP address for $COMP"
EMAIL="ematts123@gmail.com"

ip1=""
ip2=""
ip3=""
read ip1 < ip.txt
ip2=$(wget -qO- ifconfig.me/ip)
ip3=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
ip4=$(ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
if [ "$ip1" = "$ip2" ]
then
  exit
else
  echo "To: matthew.jones12@gmail.com" > ip.txt
  echo "From: NoReply@noreply.com" >> ip.txt
  echo "Subject: $SUBJ" >> ip.txt
  echo "Public IP address	-   $ip2" >> ip.txt
  echo "Wired IP address	-   $ip3" >> ip.txt
  echo "Wireless IP address	-   $ip4" >> ip.txt
  cat ip.txt | msmtp -a default $EMAIL
 
  exit
fi
