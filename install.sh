#!/usr/bin/env bash
#
# Instala e configura um servidor web completo no ambiente termux
#
# Author: Oliver Silva, 8 de julho de 2024
#
# 
#

packages=("php" "php-apache" "phpmyadmin" "mariadb" "apache2" "openssl" "openssl-tool")
version="0.0.5"
default=/sdcard/htdocs
backup=/sdcard/htdocs_backup

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

# CRIA O DIRETÓRIO HTDOCS
create_htdocs() {
  mkdir $default
  echo "<?php phpinfo(); ?>" > $default/index.php
  cp .htaccess $default
}

# VERIFICA ACESSO A MEMORIA INTERNA
check_access_internal() { 
  res=$(ls /sdcard &> /dev/null)

  while [ $? -eq 2 ] ; do
    echo -e "\e[0m\nAllow access to internal memory...[\e[1;31mNone\e[0m]"

    termux-setup-storage
    sleep 3
    res=$(ls /sdcard &> /dev/null)
  done

  echo -e "\e[0m\nAllow granted internal memory...[\e[1;32mOk\e[0m]\n"
  sleep 2

  if [ -d $default ]; then
    echo -ne "\e[0mThe '\e[1;33mhtdocs\e[0m' Project Folder was found, do you want to back it up? \e[1;33my\e[0m/\e[1;33mn\e[0m [y] : \e[0m"; read resp
    
    if [ "$resp" == "y" -o -z "$resp" ]; then
      [ ! -d $backup ] && mkdir $backup
      mv $default $backup/htdocs-$(date +%d-%m-%Y:%H:%M:%S)
      create_htdocs 
     
    elif [ "$resp" == "n" -o -z "$resp" ]; then
      rm -rf $default
      create_htdocs
    else
      echo -e "\e[0mInvalid option, only options '\e[1;33my\e[0m' and '\e[1;33mn\e[0m' are allowed.\e"
      check_access_internal
    fi

  else
    create_htdocs
  fi

  sleep 2
}

# VERIFICA SE OS PACOTES NECESSÁRIOS FORAM INSTALADOS
check_packages() {
  for package in ${packages[*]}; do
    if [ -z "$(dpkg -l | grep $package)" ]; then
      echo -e "\e[0mRequired package '\e[1;33m$package\e[0m' is not present in the system, please use the first menu option to install all necessary packages, Press the '\e[1;33mENTER\e[0m' key to return to the menu...\n\e[0m"; read
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
  echo -e "\e[0m\e[1;32mThe packages were installed successfully.\e\n[0m"
  echo -e "\e[0mPress \e[1;33mENTER\e[0m to return to the menu...\e[0m"; read
  menu
}

# DESINSTALA TODOS OS PROGRAMAS
uninstall() {
  banner "Uninstall"
  echo -e "\n\e[1;36mUninstalling all packages...\e[0m\n"

  for package in ${packages[*]}; do
    if [ -n "$(dpkg -l | grep $package)" ]; then
      echo -e "\e[1;32mUninstalling package $package...\e[0m\n"
      apt purge $package -y
    else
      echo -e "\e[0mThe \e[1;33m$package\e[0m package has already been uninstalled before.\e[0m\n"
    fi
  done
  apt autoremove -y && apt clean

  sleep 2
  echo -e "\n\e[1;32mAll packages have been uninstalled, press ENTER to return to the menu...\e[0m\n"
  read
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
    
  echo -e "\n\e[1;36mConfiguring Apache to run HTML pages...\e[0m"
  sleep 2
 
  # conf httpd
  if [ -f $PREFIX/etc/apache2/httpd.conf ]; then
    if cmp -s "./apache/httpd.conf" "$PREFIX/etc/apache2/httpd.conf"; then
      echo -e "\n\e[0mApache httpd [\e[1;32mOk\e[0m]\n" 
    else
      echo -e "\n\e[0mModifying apache httpd...\n"
      cp ./apache/httpd.conf $PREFIX/etc/apache2/httpd.conf
    fi
  else
    echo -e "\n\e[0mCreating apache httpd...\n"
    cp ./apache/httpd.conf $PREFIX/etc/apache2/httpd.conf
  fi

  # conf extra
  for program_extra_file in ./extra/*; do
    if [ -f $PREFIX/etc/apache2/extra/$(basename $program_extra_file) ]; then
      if cmp -s "$program_extra_file" "$PREFIX/etc/apache2/extra/$(basename $program_extra_file)"; then
        echo -e "\e[0mApache extra $(echo $(basename $program_extra_file) | cut -d '.' -f1) [\e[1;32mOk\e[0m]\n"
      else
        echo -e "\e[0mModifying apache $(echo $(basename $program_extra_file) | cut -d '.' -f1)....\n"
        cp $program_extra_file $PREFIX/etc/apache2/extra
      fi
    else
      echo -e "\e[0mCreating apache $(echo $(basename $program_extra_file) | cut -d '.' -f1)...\n"
      cp ./extra/$(basename $program_extra_file) $PREFIX/etc/apache2/extra
    fi
  done

  # conf ssl
  if  [ ! -d $PREFIX/etc/apache2/ssl ]; then
    echo -e "\e[0mCreating apache ssl crt e key...\n"
    mkdir $PREFIX/etc/apache2/ssl
    chmod 700 $PREFIX/etc/apache2/ssl
    cp ./ssl/* $PREFIX/etc/apache2/ssl
  else
    echo -e "\e[0mModifying apache ssl crt e key...\n"
    cp ./ssl/* $PREFIX/etc/apache2/ssl
  fi
 
  # phpmyadmin
  if [ -f $PREFIX/etc/phpmyadmin/config.inc.php ]; then
    if cmp -s "./phpmyadmin/config.inc.php" "$PREFIX/etc/phpmyadmin/config.inc.php"; then
      echo -e "\e[0mPhpMyAdmin config.inc [\e[1;32mOk\e[0m]"
    else
      echo -e "\e[0mModifying config.inc..."
      cp ./phpmyadmin/config.inc.php $PREFIX/etc/phpmyadmin/config.inc.php
    fi
  else
    echo -e "\e[0mCreating config.inc..."
    cp ./phpmyadmin/config.inc.php $PREFIX/etc/phpmyadmin/config.inc.php
  fi

   echo -e "\e\n[0mApache has been configured, press \e[1;33mENTER\e[0m to return to the menu...\n"; read
   menu
}

# CONFIGURA O PHPMYADMIN
configure_phpmyadmin() {
  banner "PhpMyAdmin"
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
  echo -e "\e[0mDirectory project: \e[1;32m/sdcard/htdocs\n\e[0m"
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

  echo -e "\n\e[1;32m\tFont: Remo773\tVersion: $version\e[0m"
  
  echo -e "\n\e[1;36mInstall and configure web server according to your wishes.\e[0m\n"
  
  n=1
  
  for option in "Install Required Packages" "Configure Apache" "Configure PhpMyAdmin" "Uninstall programs" "Exit"; do
    echo -e "\e[1;32m[\e[1;36m$n\e[1;32m] $option\e[0m"
    n=$((n +1))
  done
  
  echo -ne "\nOption: "; read option
  
  [ -z "$option" ] || [ $option -gt 5 ] || [ $option -eq 0 ] && menu
  [ "$option" == "1" ] && req_install
  [ "$option" == "2" ] && configure_apache
  [ "$option" == "3" ] && configure_phpmyadmin
  [ "$option" == "4" ] && uninstall
  [ "$option" == "5" ] && exit

}


main() {
  [ ! -n "$(dpkg -l | grep figlet)" ] && { apt update && apt upgrade && apt install figlet -yq; }
  banner "Checking"
  echo -e "\n\e[1;36mChecking requirements to run the program correctly...\e[0m"
  sleep 1
  check_os
  check_access_internal
  menu
}
main
