#!/usr/bin/env bash
#
# Instala e configura um servidor web completo no ambiente termux
#
# Author: Oliver Silva
#

packages=("php" "php-apache" "phpmyadmin" "mariadb" "apache2" "openssl" "openssl-tool" "figlet")


# BANNER
banner() {
	text="$1"
	clear
	figlet -f Remo773.flf $text
}

# VERIFICA SE RODA NO AMBIENTE TERMUX
check_os() {
	if [ -z "$TERMUX_APP__PACKAGE_NAME" ]; then
		echo -e "\e[0mOnly compatible with the Termux environment...[\e[1;31mNone\e[0m]"
		exit
	fi
	echo -e "\n\e[0mEnvironment compatible with the program...[\e[1;32mOk\e[0m]"

	sleep 1
}

# VERIFICA ACESSO A MEMORIA INTERNA
check_access_internal() {
	while [ ! -d $HOME/storage ] ; do
		echo -e "\e[0mAllow access to internal memory...[\e[1;31mNone\e[0m]\n"
		termux-setup-storage
	done

	[ ! -d /sdcard/htdocs ] && mkdir /sdcard/htdocs
	[ ! -f /sdcard/htdocs/index.php ] && {
		echo "<?php phpinfo(); ?>" > /sdcard/htdocs/index.php
	}

	echo -e "\n\e[0mAllow granted internal memory...[\e[1;32mOk\e[0m]\n"
	sleep 1
}

# VERIFICA SE OS PACOTES NECESSÁRIOS FORAM INSTALADOS
check_packages() {
	for package in ${packages[*]}; do
		if [ ! -n "$(dpkg -l | grep $package)" ]; then
			echo -e "\e[1;33mRequired package '\e[1;32m$package\e[1;33m' is not present in the system, please use the first menu option to install all necessary packages, Press the ENTER key to return to the menu...\n\e[0m"; read
			sleep 1
			menu
		fi
	done
	echo -e "\e[0mChecking packages needed for the program...[\e[1;32mOk\e[0m]\e[0m"
}

# INSTALA TODOS OS PACOTES NECESSÁRIOS
req_install() {
	banner "Packages"
	echo -e "\n\e[1;36mInstalling packages necessary to run the program...\n\e[0m"
	
	for package in ${packages[*]}; do
		if [ ! -n "$(dpkg -l | grep $package)" ]; then
			apt install $package -yq
		fi
	done
	sleep 2
	echo -e "\e[0mPress ENTER to return to the menu...\e[0m"; read
	menu
}

# MATA UM PROCESSO EM SEGUNDO PLANO
kill_process() {
	process_name="$1"

	[ -n "$(ps -e | grep $process_name)" ] && pkill -f /data/data/com.termux/files/usr/bin/$process_name
	sleep 2
}

# CONFIGURA O APACHE
configure_apache() {
	banner "Apache"
	echo
	check_packages

	echo -e "\n\e[1;36mConfiguring Apache to run HTML pages..\n\e[0m"
	sleep 1
	cp apache/* $PREFIX/etc/apache2

	[ ! -d $PREFIX/etc/apache2/ssl ] && mkdir $PREFIX/etc/apache2/ssl
	chmod 700 $PREFIX/etc/apache2/ssl
	cp ssl/* $PREFIX/etc/apache2/ssl
	cp extra/* $PREFIX/etc/apache2/extra
	cp phpmyadmin/* $PREFIX/etc/phpmyadmin
	echo -e "\e[0mApache has been configured, press ENTER to return to the menu...\n"; read
	menu
}

# CONFIGURA O PHPMYADMIN
configure_phpmyadmin() {
	banner "phpmyadmin"
	echo
	check_packages

	echo -e "\n\e[1;36mRunning mariadbd in the background, please wait...\e[0m"
	kill_process "mariadbd"
	mariadbd-safe -u root > /dev/null &
	sleep 6

	echo -e "\n\e[1;36mConfiguring access to phpmyadmin..\n\e[0m"
	sleep 1

	echo -ne "User name: " ; read username
	echo -ne "Password: " ; read password
	echo -ne "\n\e[1;36mProcessing the command, please wait...\e[0m\n"
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
	echo -e "\e[0mUser name: \e[1;32m$username\e[0m"
	echo -e "\e[0mPassword: \e[1;32m$password\e[0m"
	echo -e "\e[0mLink: \e[1;32mhttps://localhost:8443/phpmyadmin\n\e[0m"
	echo -e "\e[0mDirectory project: \e[1;32m/data/data/com.termux/files/usr/share/apache2/default-site/htdocs\n\e[0m"
	echo -e "\e[0mStart the mariadb server with: \e[1;32mmariadbd-safe -u $username &\n\e[0m"
	echo -e "\e[0mStop mariadb server with: \e[1;32mpkill -f /data/data/com.termux/files/usr/bin/mariadbd\n\e[0m"

	kill_process "mariadbd"
	echo -e "phpmyadmin has been configured, press ENTER to return to the menu...\n"; read
	menu

}

goodbye() {
	kill_process "mariadbd"
	echo -e "\n\n\e[1;31mProgram interrupt.\e[0m\n"; exit; 
}

menu() {
	trap "goodbye" SIGTSTP SIGINT
	clear
	banner "Menu IWS"

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

	[ -z "$option" -o "$option" -gt 4 -o "$option" -eq 0 ] && menu
	[ "$option" == "1" ] && req_install && menu
	[ "$option" == "2" ] && configure_apache && menu
	[ "$option" == "3" ] && configure_phpmyadmin && menu
	[ "$option" == "4" ] && exit

}


main() {
	[ ! -n "$(dpkg -l | grep figlet)" ] && { apt update && apt upgrade -yq && apt install figlet -yq; }
	banner "Checking"
	echo -e "\nChecking requirements to run the program correctly..."
	sleep 1
	check_os
	check_access_internal
	check_packages
	menu
}
main
