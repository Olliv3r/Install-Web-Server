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

	[ ! -d $PREFIX/etc/apache2/ssl ] && mkdir $PREFIX/etc/apache2/ssl
	chmod 700 $PREFIX/etc/apache2/ssl
	cp ssl/* $PREFIX/etc/apache2/ssl
	cp extra/* $PREFIX/etc/apache2/extra
	cp phpmyadmin/* $PREFIX/etc/phpmyadmin
	echo "Apache has been configured, press ENTER to return to the menu."; read
	menu
}

configure_phpmyadmin() {
	banner
	echo -e "\nRunning mariadbd in the background, please wait...\n"
	pkill -f data/data/com.termux/files/usr/bin/mariadbd
	mariadbd-safe -u root > /dev/null &
	sleep 6

	echo -e "\n\e[1;36mConfiguring access to phpmyadmin..\n\e[0m"
	sleep 1

	echo -ne "User name: " ; read username
	echo -ne "Password: " ; read password
	echo -ne "\n\e[1;32mProcessing the command, please wait...\e[0m\n"
	sleep 1

	if [ -z "$username" -o -z "$password" ]; then
		echo -e "\n\e[1;31mPanel access data is required.\n\e[0m"
		echo -e "\e[1;33mPress ENTER to return to configuring access.\e[0m"
		read
		configure_phpmyadmin
	fi


	user=$(mariadb -u root -D mysql -e "SELECT user FROM user WHERE user='$username'")

	if [ -n "$user" ]; then
		echo -e "\n\e[1;33mThis user already exists, try another username. Press ENTER to try again.\n\e[0m"
		read
		configure_phpmyadmin
	fi

	mariadb -u root -D mysql -e "CREATE USER '$username'@'localhost' IDENTIFIED BY '$password';GRANT ALL PRIVILEGES ON * . * TO '$username'@'localhost';FLUSH PRIVILEGES;"

	[ -d $PREFIX/etc/phpmyadmin ] && cp phpmyadmin/* $PREFIX/etc/phpmyadmin
	sleep 2
	echo -e "\n\e[1;32mYour new login to the phpmyadmin panel:\e[0m\n"
	echo -e "\e[0mUser name: \e[2;32m$username\e[0m"
	echo -e "\e[0mPassword: \e[2;32m$password\e[0m"
	echo -e "\nLink: \e[28;32mhttps://localhost:8443/phpmyadmin\n\e[0m"
	pkill -f /data/data/com.termux/files/usr/bin/mariadbd
	echo "phpmyadmin has been configured, press ENTER to return to the menu."; read
	menu

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


main() {
	check_os
	apt update && apt upgrade -y
	apt install figlet -yq
	menu
}
main
