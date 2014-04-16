#!/bin/bash
# VeePeeNee 1.1
# http://www.top-hat-sec.com
# By: d4rkcat & R4v3N - till 1.0
# Forked by: EclipseSpark <eclipse@frozenbox.org> from 1.1 onwards
# We couldnt thought a better name for this script! lulz 8===D
# Please be responsible!

fgetcerts()
{
	# download certs
	mkdir -p /var/veepeenee
	mkdir -p /var/veepeenee/certs
	cd /var/veepeenee/certs
	rm *
	wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-Euro1.zip -O euro1.zip
	wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-Euro2.zip -O euro2.zip
	wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-UK1.zip -O uk1.zip
	wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-US1.zip -O us1.zip
	for ITEM in $(ls | grep .zip);do unzip $ITEM;done
	for ITEM in $(ls);do echo -e '\nauth-user-pass "creds"' >> $ITEM;done
	rm *.zip
	cp *.ovpn ../vpnbook/*
}

fgetcreds()
{
	# mkdir & get the creds
	mkdir -p /var/veepeenee
	mkdir -p /var/veepeenee/vpnbook
	cd /var/veepeenee/vpnbook
	echo vpnbook > creds && curl -s www.vpnbook.com | grep Password | tr -d ' ' | head -n 1 | cut -d '>' -f 3 | cut -d ':' -f 2 | cut -d '<' -f 1 >> creds
}

fdnsmake()
{
		if [ ! -f /etc/resolv.conf.bak ] 2> /dev/null
		then
				mv /etc/resolv.conf /etc/resolv.conf.bak
		fi

		read -p ''' [>] Please select the DNS provider:

 [1] Google
 [2] CCCDNS (Chaos Computer Club)
 [3] FrozenDNS (frozenbox network)

 >''' DNSPROVIDER

echo -e '\n [*] Changeing DNS provider.'

		if [ $DNSPROVIDER = '1' ] 2> /dev/null
		then
			echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' > /etc/resolv.conf
		else
			if [ $DNSPROVIDER = '2' ] 2> /dev/null
			then
				echo -e 'nameserver 213.73.91.35\nnameserver 194.150.168.168' > /etc/resolv.conf
			else
				if [ $DNSPROVIDER = '3' ] 2> /dev/null
				then
					echo -e 'nameserver 199.175.54.136\nnameserver 192.3.163.156' > /etc/resolv.conf
				fi
			fi
		fi
}

fsetupvpn()
{
		read -p '''
 [>] Please select the vpn country:

 [1] USA
 [2] UK
 [3] EU

 >''' COUNTRY
		read -p '''
 [>] Please select the vpn port:

 [1] TCP 80
 [2] TCP 443
 [3] UDP 25000

 >''' PORT
		if [ $COUNTRY = '1' ] 2> /dev/null
		then
			COUNTRY='USA'
			if [ $PORT = '1' ] 2> /dev/null
			then
				terminator -e "openvpn /var/veepeenee/vpnbook/vpnbook-us1-tcp80.ovpn" 2> /dev/null&
			elif [ $PORT = '2' ] 2> /dev/null
			then
				terminator -e "openvpn /var/veepeenee/vpnbook/vpnbook-us1-tcp443.ovpn" 2> /dev/null&
			elif [ $PORT = '3' ] 2> /dev/null
			then
				terminator -e "openvpn /var/veepeenee/vpnbook/vpnbook-us1-upd25000.ovpn" 2> /dev/null&
			fi
		elif [ $COUNTRY = '2' ] 2> /dev/null
		then
				COUNTRY='UK'
				if [ $PORT = '1' ] 2> /dev/null
				then
					terminator -e "openvpn /var/veepeenee/vpnbook/vpnbook-uk1-tcp80.ovpn" 2> /dev/null&
				elif [ $PORT = '2' ] 2> /dev/null
				then
					terminator -e "openvpn /var/veepeenee/vpnbook/vpnbook-uk1-tcp443.ovpn" 2> /dev/null&
				elif [ $PORT = '3' ] 2> /dev/null
				then
					terminator -e "openvpn /var/veepeenee/vpnbook/vpnbook-uk1-upd25000.ovpn" 2> /dev/null&
				fi
		else
				COUNTRY='EU'
				if [ $PORT = '1' ] 2> /dev/null
				then
						terminator -e "openvpn /var/veepeenee/vpnbook/vpnbook-euro2-tcp80.ovpn" 2> /dev/null&
				elif [ $PORT = '2' ] 2> /dev/null
				then
						terminator -e "openvpn /var/veepeenee/vpnbook/vpnbook-euro2-tcp443.ovpn" 2> /dev/null&
				elif [ $PORT = '3' ] 2> /dev/null
				then
					terminator -e "openvpn /var/veepeenee/vpnbook/vpnbook-euro2-upd25000.ovpn" 2> /dev/null&
				fi
		fi
	echo -e "\n [*] VPN setup complete, Welcome to the $COUNTRY"
}


fgetdeps()
{
	if [ [ $(which openvpn) -z ] 2> /dev/null
	then
		read -p ' [>] openvpn was not found on this system, install now? [Y/n]
	 >' INSTALL
		case $INSTALL in
			"y") ANS3=1;;
			"Y") ANS3=1;;
			"") ANS3=1
		esac
		if [ $ANS3 = '1' ] 2> /dev/null
		then
			apt-get install openvpn
		fi
	fi
}

if [ $(whoami) = 'root' ]
then
fgetdeps
else
	echo ' [X] This script must be run as root.'
	exit
fi

fgetcreds

# Download files?
echo " [*] doanloading certs...."
fgetcerts

# change dns?
read -p '''
 [>] Do you want to change your DNS? [Y/n]
 >' CHANGEDNS

case $CHANGEDNS in
		"Y") ANS=1;; 
		"y") ANS=1;;
		"") ANS=1
esac

if [ $ANS = 1 ] 2> /dev/null
then
		fdnsmake
else
		echo " [*] Skipping..."
fi

fsetupvpn
