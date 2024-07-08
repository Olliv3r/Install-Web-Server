#!/usr/bin/env bash
#
#

# VERIFICA SE RODA NO AMBIENTE TERMUX
check_os() {
	if [ -z "$TERMUX_APP__PACKAGE_NAME" ]; then
		echo "Only compatible with the Termux environment."
		exit
	fi
}

banner() {
	clear
	figlet -f Remo773.flf "Install"
}

spin() {
	pid=$!
	delay=0.25
	spinner=('█■■■■' '■█■■■' '■■█■■' '■■■█■' '■■■■█')

	while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
		for i in ${spinner[*]}; do
			tput civis
			echo -ne "\e[1;32m\r[*] Downloading, please wait...$i\e[0m"
			sleep $delay
			printf "\b\b\b\b\b\b\b\b"
		done
	done
	tput cnorm
	echo -e "\e[1;32m\r[+] Downloading, please wait...[Done]\e[0m\n"
	echo
}

req_install() {
	banner
	echo -e "\n\e[1;36mInstalling packages necessary to run the program.\n\e[0m"
	apt install php php-apache phpmyadmin mariadb apache2 openssl openssl-tool -yq
	sleep 2
}

configure_apache() {
	banner
	echo -e "\n\e[1;36mConfiguring Apache to run HTML pages..\n\e[0m"
	cp apache/* $PREFIX/etc/apache2

	[ ! -d $PREFIX/etc/apache2/ssl ] && sleep 2 && mkdir $PREFIX/etc/apache2/ssl
	cp ssl/* $PREFIX/etc/apache2/ssl
	cp extra/* $PREFIX/etc/apache2/extra
	echo "Apache has been configured, press ENTER to return to the menu."; read
	menu
}

configure_phpmyadmin() {
	banner
	echo -e "\n\e[1;36mConfiguring access to phpmyadmin..\n\e[0m"
	sleep 1

	echo "User name: " ; read user
	echo "Password: " ; read password

	if [ -z "$user" -o -z "$password" ]; then
		echo -e "\n\e[1;31mPanel access data is required.\n\e[0m"
		echo -e "\e[1;33mPress ENTER to return to configuring access.\e[0m"
		read
		configure_phpmyadmin
	fi

	mysqld_safe -u root &> /dev/null &
	sleep 2
	
	mysql -u root -D mysql -e "use mysql;CREATE USER '$user'@'localhost' IDENTIFIED BY '$password';GRANT ALL PRIVILEGES ON * . * TO '$user'@'localhost';FLUSH PRIVILEGES;"

	[ -d $PREFIX/etc/phpmyadmin ] && cp phpmyadmin/* $PREFIX/etc/phpmyadmin
	sleep 2
	echo -e "\n\e[1;32mYour new login to the phpmyadmin panel:\e[0m\n"
	echo -e "\e[0mUser name: \e[2;32m$user\e[0m"
	echo -e "\e[0mPassword: \e[2;32m$password\e[0m"
	echo -e "\nLink: \e[28;32mhttps://localhost:8443/phpmyadmin\n\e[0m"
	pkill mysqld_safe
	pkill mariadbd
	echo "phpmyadmin has been configured, press ENTER to return to the menu."; read

}

goodbye() { echo -e "\n\n\e[1;31mProgram interrupt.\e[0m\n"; exit; }

menu() {
	trap "goodbye" SIGTSTP SIGINT
	clear
	banner

	echo -e "\n\e[1;36mInstall and configure web server according to your wishes.\e[0m\n"

	n=1
	
	for option in "Install Required Packages" \
		      "Configure Apache" \
		      "Configure PhpMyAdmin" \
		      "Exit"; do 
		echo -e "\e[1;32m[\e[1;36m$n\e[1;32m] $option\e[0m"
		n=$((n +1))
	done

	echo -ne "\nOption: "; read option
	echo $option

	[ -z "$option" ] && menu
	[ "$option" == "1" ] && req_install && menu
	[ "$option" == "2" ] && configure_apache && menu
	[ "$option" == "3" ] && configure_phpmyadmin && menu
	[ "$option" == "4" ] && exit

}


menu
