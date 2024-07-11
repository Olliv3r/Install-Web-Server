# Install-Web-Server
Instala e configura um servidor web completo de forma automática.

### Captura:
![Tela](https://github.com/Olliv3r/Install-Web-Server/blob/main/tela.jpg)

### O que faz?
O `install` é um instalador de servidor web completo pra termux, podendo instalar e configurar o `Apache` e `PhpMyAdmin` diretamente no ambiente termux sem o uso do super-usuário (root).

### Instalação:
Instalar o git:
```
apt update && apt upgrade && apt install git -yq
```

Clonar o repositório:
```
git clone https://github.com/Olliv3r/Install-Web-Server.git
```

Executar o script:
```
cd Install-Web-Server && bash install.sh
```

> [!WARNING]
> Para conseguir instalar o servidor web no ambiente termux, é necessário escolher as opçôes por ordem númerica na forma acrescente. Comece instalando os pacotes necessários na *primeira opção*, depois configure o Apache no *segunda opção* e por fim configure o PhpMyAdmin (Opcional) na *terceira opção*.

### Desinstalar:
Caso queira desinstalar todos os programas instalados pelo `install`, basta escolher a *quarta opção*.


### Opçôes:
1. Instala todos os pacotes necessários
2. Configura o apache para projetos 
3. Configura o acesso ao painel do phpmyadmin (Opcional)
4. Desinstala pacotee instalados na *primeira opção*
5. Sai do programa

### Bônus:

##### Apache:
Para iniciar o servidor apache, execute o comando:
```
apachectl -k start
```
Para encerrar o servidor apache, execute o comando:
```
apachectl -k stop
```
##### Mariadb:
Para iniciar o servidor mariadbd-safe, execute o comando:
```
mariadbd-safe -u SEU_USUARIO &
```
Para encerrar o servidor mariadbd-safe, execute o comando:
```
pkill -f /data/data/com.termux/files/usr/bin/mariadbd
```

### Recursos:
- [x] Hospedagem de projetos em /sdcard/htdocs
- [x] Painel do PhpMyAdmin
- [x] URL Amigável habilitado


@silva_olie :+1: Boa sorte! :shipit:
