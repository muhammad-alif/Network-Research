#! bin/bash

#------------Helper Functions-------------------
# Here are the functions pre coded so that in case the code needs to 
# call a function multiple times, we can just call the function
# header

function commandCheck(){
	installVar=$1
	case $installVar in
		"nipe.pl")	
					locate nipe.pl > /dev/null
					if [ $? -eq 0 ];
					then 
						echo "[#] Nipe is already installed"
					else
						echo "[#] Nipe is not installed"
						installapp $installVar
					fi
		;;
		"geoiplookup")
					if command -v geoiplookup &> /dev/null
					then 
					echo "[#] geoip-bin is already installed"
					else
					echo "[#] geoip-bin is not installed"
					installapp $installVar
					fi
		;;
		"sshpass")
					if command -v sshpass &> /dev/null
					then 
					echo "[#] sshpass is already installed"
					else
					echo "[#] sshpass is not installed"
					installapp $installVar
					fi
		;;
		esac		
}
function installapp(){
	
	case $1 in
		"nipe.pl")
			echo "install ? [y/n]"
			read option
			if [ $option == 'y' ] || [ $option == 'Y' ]; then
			git clone https://github.com/htrgouvea/nipe && cd nipe
			sleep 5
			sudo cpan install Try::Tiny Config::Simple JSON
			sleep 5
			sudo perl nipe.pl install
			else
			echo 'Cannot proceed without anonymity, will be exiting'
			exit
			fi
		;;
		"geoiplookup")
			echo "install ? [y/n]"
			read option
			if [ $option == 'y' ] || [ $option == 'Y' ]; then
			sudo apt-get install geoip-bin
			else
			echo "since geoiplookup is not installed the country will be blank"
			fi
		;;
		"sshpass")
			echo "install ? [y/n]"
			read option
			if [ $option == 'y' ] || [ $option == 'Y' ]; then
			sudo apt-get install sshpass
			else
			echo "will be exiting"
			exit
			fi
		;;
	esac
}

function startNipe(){
	oriWorkDrive=$(pwd)
	cd $(dirname $(locate nipe.pl) )
	sudo perl nipe.pl stop
	echo '[!]Starting nipe service:'
	sleep 5
	sudo perl nipe.pl start
	sleep 5
	sudo perl nipe.pl restart
	sleep 5
	spoofaddr=$(curl ifconfig.me)
}

function remoteControl(){
	echo "[?]Specify a Domain/IP address to scan along with username and password:"
	read remoteaddr userID pass
	echo "[*] Connecting to Remote Server:"
	echo $remoteaddr
	if [[ $remoteaddr =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] 
	then 
		ip=$remoteaddr
		sshpass -p $pass ssh $userID@$remoteaddr  "curl -s ipinfo.io | grep country; curl -s ipinfo.io | grep -w ip; uptime"
	else
		ip=$(nslookup $remoteaddr | grep -i address: | grep -v '#' | awk -F ':' '{print $2}')
		ip="${ip// /}"
		echo $ip
		echo "sudo curl https://ipinfo.io/$ip"
		sudo curl https://ipinfo.io/$ip 
	fi
}

function dataExtraction(){
	cd $oriWorkDrive
	workdrive=$(pwd)
	echo $workdrive
	mkdir NetworkResearchOutput
	cd NetworkResearchOutput
	echo '[!] Whoising victims address:'
	whois $ip > whoisOutput
	echo "[@] placed data in ${workdrive}"
	echo '[!] Scanning victims address: '
	sudo nmap -sV -F -Pn -sS $ip -oA nmapOutput
	echo "[@] placed data in ${workdrive}"
	echo "[!] Updating logs:"
	echo "Program execution complete !!"
	echo "$(whoami) used the net work research program at $(date)"
	echo "The target was ${ip}"
	echo "$(date) : Whois data of ${ip} is placed in ${workdrive}" >> log.audit
	echo "$(date) : nmap data of ${ip} is placed in ${workdrive}" >> log.audit
}

# Q1. Installations and Anonymity check (50 Pts)
# Install needed apps
# If apps already installed, dont install 
# check if network connection is anonymous, if not, alert user and exit
# Once network connection is anonymous, display spoofed country name
# Allow user to specify domain/IP addr and save into variable
echo 'Updating Package Repository:'
sudo apt-get update

commandCheck "nipe.pl"
commandCheck "geoiplookup"
commandCheck "sshpass"
echo '[!]Program will now start the nipe process:'

startNipe

echo '[!]You are now anonymous...'
echo '[!]This is your spoofed IP address and country:'
echo "[!]IP: ${spoofaddr}"
echo "[!]Addr: $(geoiplookup ${spoofaddr})"

# Q2. Auto Connect and execute commands on Remote Server via SSH (30 Pts)
# Display details of remote server(Country, IP and Uptime)
# Get remote server to check Whois of given address
# Get the remote server to scan for open ports
remoteControl 

# Q3. Results (15 Pts)
# Save Whois and nmap data into files of local computer
# Create a log and audit data collecting
dataExtraction
     
     

