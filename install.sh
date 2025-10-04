#!/usr/bin/env bash
#
# Instala e configura um servidor web completo no ambiente Termux
#
# Autor: Oliver Silva, 8 de julho de 2024
#

# Pacotes necessários
PACKAGES_REQUIRED=(
    "php"
    "php-apache"
    "phpmyadmin"
    "mariadb"
    "apache2"
    "openssl"
    "openssl-tool"
)

# Configurações do script
SCRIPT_VERSION="0.0.6"
DEFAULT_DIR="/sdcard/htdocs"
BACKUP_DIR="/sdcard/htdocs_backup"

# EXIBE BANNER ESTILIZADO
banner() {
    clear
    figlet -f Remo773.flf "$1" 2>/dev/null || echo "=== $1 ==="
}

# VERIFICA SE ESTÁ RODANDO NO AMBIENTE TERMUX
check_os() {
    if [ -z "$TERMUX_APP__PACKAGE_NAME" ]; then
        echo -e "\e[0mSomente compatível com o ambiente Termux...[\e[1;31mFalhou\e[0m]"
        exit
    fi

    echo -e "\n\e[0mAmbiente compatível com o programa...[\e[1;32mOk\e[0m]"
    sleep 1
}

# REMOVER TODOS OS ARQUIVOS E DIRETÓRIOS CRIADOS PELO SCRIPT
cleanup_script() {
    echo -e "\nLimpando arquivos do script..."

    # Remover configurações do Apache
    rm -rf "$PREFIX/etc/apache2/httpd.conf"
    rm -rf "$PREFIX/etc/apache2/extra/"*
    rm -rf "$PREFIX/etc/apache2/ssl/"

    # Remover configuração do PHPMyAdmin
    rm -rf "$PREFIX/etc/phpmyadmin/config.inc.php"

    # Remover diretório web (pergunta por confirmação)
    if [ -d "$DEFAULT_DIR" ]; then
        read -p "❓ Remover diretório $DEFAULT_DIR? [s/N]: " resp
        [[ $resp =~ ^[Ss]$ ]] && rm -rf "$DEFAULT_DIR"
    fi

    echo -e "\n✅ Limpeza concluída!"
    echo -e "\n\e[0mPressione \e[1;33mENTER\e[0m para retornar ao menu...\e[0m\n"; read

    menu
}

# CRIA O DIRETÓRIO HTDOCS E COPIA ARQUIVOS
create_htdocs() {
	if [ ! -d "$DEFAULT_DIR" ]; then
		mkdir -p "$DEFAULT_DIR"
		cp apache/.htaccess apache/index.php "$DEFAULT_DIR" 2>/dev/null
		echo -e "\n✅ Diretório de projetos criado em \e[1;33m$DEFAULT_DIR\e[0m...[\e[1;32mOK\e[0m]"
	else
		cp apache/.htaccess apache/index.php "$DEFAULT_DIR" 2>/dev/null
    	echo -e "\n✅ Diretório de projetos existente em \e[1;33m$DEFAULT_DIR\e[0m...[\e[1;32mOK\e[0m]"
    fi

}

# VERIFICA ACESSO À MEMÓRIA INTERNA
check_storage_access() {
    echo -e "\033[1;36m\nVerificando acesso ao armazenamento...\033[0m\n"
    sleep 2

    # Verificação rápida inicial
    if ls /sdcard &>/dev/null; then
        echo -e "\e[0mAcesso imediato confirmado...[\e[1;32mOK\e[0m]"
        sleep 2
        return 0
    fi

    # Se falhar, solicitar permissão uma vez
    echo -e "\033[1;33mSolicitando permissão...\033[0m"
    termux-setup-storage
    sleep 5

    # Verificação final
    if ls /sdcard &>/dev/null; then
        echo -e "\033[1;32m✓ Acesso concedido após solicitação\033[0m"
        sleep 2
        return 0
    else
        echo -e "\033[1;31m✗ Acesso ainda negado após solicitação\033[0m"
        sleep 2
        return 1
    fi
}

# VERIFICA SE OS PACOTES NECESSÁRIOS FORAM INSTALADOS
check_packages() {
    for package in "${PACKAGES_REQUIRED[@]}"; do
        dpkg -l "$package" &>/dev/null || return 1       
    done
    
    return 0
}

# Verifica a existencia de um pacote
check_package() {
	if [ -n "$(dpkg -l "$1" | grep "$1")" ]; then
		return 0
	fi

	return 1
}

# DESINSTALA OS PROGRAMAS
req_uninstall() {
	banner "Pacotes"

	echo -e "\033[1;36m\nDesinstalando pacotes...\033[0m\n"

	for package in "${PACKAGES_REQUIRED[@]}"; do
		if check_package "$package" 2>/dev/null; then
			apt purge "$package" -yq

			if ! check_package "$package" 2>/dev/null; then
				echo -e "\e[0m\nPacote $package desinstalado...[\e[1;32mOK\e[0m]"
			else
				echo -e "\e[0m\nNão é possível desinstalar o \e[1;33m$package\e[0m...\n"
			fi
			
		else
			echo -e "\n\e[0mO pacote \e[1;33m$package\e[0m já foi desinstalado antes...\e[0m"
		fi
	done

    echo -e "\e[0mPressione \e[1;33mENTER\e[0m para retornar ao menu...\e[0m"; read
    menu
}

# INSTALA OS PROGRAMAS
req_install() {
	banner "Pacotes"

	echo -e "\033[1;36m\nInstalando pacotes...\033[0m\n"

	for package in "${PACKAGES_REQUIRED[@]}"; do
		if ! check_package "$package" 2>/dev/null; then
			apt install "$package" -yq

			if check_package "$package" 2>/dev/null; then
				echo -e "\e[0m\nPacote $package instalado...[\e[1;32mOK\e[0m]\n"
			else
				echo -e "\e[0m\nNão é possível instalar o \e[1;33m$package\e[0m...\n"
			fi
						
		else
			echo -e "\n\e[0mO pacote \e[1;33m$package\e[0m já está instalado!"
		fi
	done
	
    echo -e "\n\e[0mPressione \e[1;33mENTER\e[0m para retornar ao menu...\e[0m"; read
    menu
}

# MATA UM PROCESSO EM SEGUNDO PLANO
kill_process() {
    pkill -f "$1" 2>/dev/null
}

create_cmd_tamp() {
  cat > $PREFIX/bin/tamp-start << EOF
#!/bin/bash
echo -e "[\e[1;34m*\e[0m] Iniciando TAMP Server..."

if ! pgrep mariadbd >/dev/null && ! pgrep httpd >/dev/null; then
  apachectl start && mariadbd-safe -u root &

  sleep 3

  if pgrep mariadbd >/dev/null && pgrep httpd >/dev/null; then
    echo -e "[\e[1;32m+\e[0m] TAMP Server iniciado:"
    echo -e "[\e[1;36m?\e[0m] Acesse: http://localhost:8080"
    echo -e "[\e[1;36m?\e[0m] Acesse: http://localhost:8080/phpmyadmin"
    exit 0
  else
    echo -e "[\e[1;31m×\e[0m] TAMP Server não iniciado!"
    exit 1
  fi

else
  echo -e "[\e[1;33m!\e[0m] TAMP Server ja está rodando!"
  exit 0
fi
EOF

cat > $PREFIX/bin/tamp-stop << EOF
#!/bin/bash
echo -e "[\e[1;34m*\e[0m] Parando TAMP Server..."

if pgrep mariadbd >/dev/null && pgrep httpd >/dev/null; then
  apachectl stop >/dev/null && pkill -f mariadbd
  sleep 1

  if ! pgrep mariadbd >/dev/null && ! pgrep httpd >/dev/null; then
    echo -e "[\e[1;32m√\e[0m] TAMP Server parado."
    exit 0
  else
    echo -e "[\e[1;31m×\e[0m] Falha ao parar o TAMP Server!"
    exit 1
  fi
else
  echo -e "[\e[1;33m!\e[0m] TAMP Server já foi parado!"
  exit 0
fi
EOF

cat > $PREFIX/bin/tamp-status << EOF
#!/bin/bash
echo -e "[\e[1;34m-\e[0m] Status TAMP Server:\n"

if pgrep mariadbd >/dev/null && pgrep httpd >/dev/null; then
  echo -e "[\e[1;32m√\e[0m] Apache rodando"
  echo -e "[\e[1;32m√\e[0m] MariaDB rodando"
else
  echo -e "[\e[1;31m×\e[0m] Apache parado"
  echo -e "[\e[1;31m×\e[0m] Apache parado"
fi
EOF

  # Dar permissões de execução
  chmod +x $PREFIX/bin/tamp-*
  sleep 1
  echo -e "\e[0m\n[+] Criando comandos TAMP...[\e[1;32mOK\e[0m]\e[0m"
}

# CONFIGURA O APACHE
configure_apache() {
    banner "Apache"
    if check_packages; then
    	echo -e "\e[0m\nVerificando pacotes necessários para o programa...[\e[1;32mOk\e[0m]\e[0m"
    	sleep 1
	else
		echo -e "\n\e[0mPacote necessário não está presente no sistema, por favor use a primeira opção do menu para instalar todos os pacotes necessários, Pressione a tecla '\e[1;33mENTER\e[0m' para retornar ao menu...\n\e[0m"; read
		menu
    fi

    echo -e "\n\e[1;36mConfigurando Apache para executar páginas HTML...\e[0m"

    # Função auxiliar para copiar se diferente
    copy_if_different() {
        local src="$1" dst="$2"
        if [ ! -f "$dst" ] || ! cmp -s "$src" "$dst"; then
            mkdir -p "$(dirname "$dst")"
            cp "$src" "$dst" && echo -e "\n✅ $(basename "$src")"
        fi
    }

    # Copia todos os arquivos
    copy_if_different "./apache/httpd.conf" "$PREFIX/etc/apache2/httpd.conf"

    for file in ./extra/*; do
        [ -f "$file" ] && copy_if_different "$file" "$PREFIX/etc/apache2/extra/$(basename "$file")"
    done

    mkdir -p "$PREFIX/etc/apache2/ssl"
    chmod 700 "$PREFIX/etc/apache2/ssl"
    cp ./ssl/* "$PREFIX/etc/apache2/ssl/" 2>/dev/null && echo -e "\n✅ SSL"

    copy_if_different "./phpmyadmin/config.inc.php" "$PREFIX/etc/phpmyadmin/config.inc.php"

    create_htdocs

    # Criar comandos TAMP
    create_cmd_tamp

    echo -e "\e\n[0mApache foi configurado, pressione \e[1;33mENTER\e[0m para retornar ao menu...\n"; read
    menu
}

# CONFIGURA O PHPMYADMIN
configure_phpmyadmin() {
    banner "PhpMyAdmin"
    echo
    
    if check_packages; then
     	echo -e "\e[0m\nVerificando pacotes necessários para o programa...[\e[1;32mOk\e[0m]\e[0m"
     	sleep 1
 	else
 		echo -e "\n\e[0mPacote necessário não está presente no sistema, por favor use a primeira opção do menu para instalar todos os pacotes necessários, Pressione a tecla '\e[1;33mENTER\e[0m' para retornar ao menu...\n\e[0m"; read
 		menu
     fi

    echo -e "\n\e[1;36mExecutando mariadbd em segundo plano, por favor aguarde...\e[0m"
    kill_process "mariadbd"
    mariadbd-safe -u root > /dev/null &
    sleep 6

    echo -e "\n\e[1;36mConfigurando acesso ao phpmyadmin..\n\e[0m"
    sleep 1

    echo -ne "Nome de usuário: " ; read username
    echo -ne "Senha: " ; read password
    echo -ne "\n\e[1;36mProcessando o comando, por favor aguarde...\e[0m\n"
    sleep 1

    if [ -z "$username" -o -z "$password" ]; then
        echo -e "\n\e[1;31mDados de acesso ao painel são obrigatórios.\n\e[0m"
        echo -e "\e[1;33mPressione ENTER para retornar à configuração de acesso.\e[0m"
        read
        configure_phpmyadmin
    fi

    user=$(mariadb -u root -D mysql -e "SELECT user FROM user WHERE user='$username'")

    if [ -n "$user" ]; then
        echo -e "\n\e[1;33mEste usuário já existe, tente outro nome de usuário. Pressione ENTER para tentar novamente.\n\e[0m"
        read
        configure_phpmyadmin
    fi

    mariadb -u root -D mysql -e "CREATE USER '$username'@'localhost' IDENTIFIED BY '$password';GRANT ALL PRIVILEGES ON * . * TO '$username'@'localhost';FLUSH PRIVILEGES;"

    [ -d $PREFIX/etc/phpmyadmin ] && cp phpmyadmin/* $PREFIX/etc/phpmyadmin
    sleep 2

    echo -e "\n\e[1;32mSeu novo login para o painel phpmyadmin:\e[0m\n"
    echo -e "\e[0mNome de usuário: \e[1;32m$username\e[0m"
    echo -e "\e[0mSenha: \e[1;32m$password\e[0m"
    echo -e "\e[0mLink: \e[1;32mhttps://localhost:8443/phpmyadmin\n\e[0m"
    echo -e "\e[0mDiretório do projeto: \e[1;32m/sdcard/htdocs\n\e[0m"
    echo -e "\e[0mInicie o servidor mariadb com: \e[1;32mmariadbd-safe -u $username &\n\e[0m"
    #echo -e "\e[0mPare o servidor mariadb com: \e[1;32mpkill -f /data/data/com.termux/files/usr/bin/mariadbd\n\e[0m"
    echo -e "\e[0mPare o servidor mariadb com: \e[1;32mpkill -f mariadbd\n\e[0m"

    kill_process "mariadbd"
    echo -e "phpmyadmin foi configurado, pressione ENTER para retornar ao menu...\n"; read
    menu
}

# FUNÇÃO DE SAÍDA
goodbye() {
    kill_process "mariadbd" && echo -e "\n\n\e[1;31mPrograma encerrado.\e[0m\n"; exit;
}

# MENU PRINCIPAL
menu() {
    trap "goodbye" SIGTSTP SIGINT
    clear
    banner "Menu TAMP"

    echo -e "\n\e[1;32m\tFonte: Remo773\tVersão: $SCRIPT_VERSION\e[0m"

    echo -e "\n\e[1;36mInstale e configure o servidor web de acordo com suas preferências.\e[0m\n"

    n=1

    for option in "Instalar Pacotes Necessários" "Configurar Apache" "Configurar PhpMyAdmin" "Desinstalar programas" "Limpar arquivos" "Sair"; do
        echo -e "\e[1;32m[\e[1;36m$n\e[1;32m] $option\e[0m"
        n=$((n +1))
    done

    echo -ne "\nOpção: "; read option

    case "$option" in
		1) req_install;;
		2) configure_apache;;
		3) configure_phpmyadmin;;
		4) req_uninstall;;
		5) cleanup_script;;
		6) exit;;
		*) echo -e "\nOpção inválida!\n" && sleep 1 && menu;;
    esac
}

# FUNÇÃO PRINCIPAL
main() {
    ! check_package "figlet" && { apt update && apt upgrade && apt install figlet -yq; }
    
    banner "Verificando"
    echo -e "\n\e[1;36mVerificando requisitos para executar o programa corretamente...\e[0m"
    sleep 1

	# Verifica a compatibilidade do sistema
    check_os

    # Verifica acesso ao armazenamento
    if ! check_storage_access; then
		echo -e "\n\e[0mAcesso a memoria ainda não permitido, permita o acesso manualmente com o comando '\e[1;33mtermux-setup-storage\e[0m' , Pressione a tecla '\e[1;33mENTER\e[0m' para retornar ao menu...\n\e[0m"; read
    	menu
    fi
    menu

}

main
