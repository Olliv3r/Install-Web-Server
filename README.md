# Install-Web-Server
Instala e configura um servidor web completo de forma automática.

### Captura:
![Tela](https://github.com/Olliv3r/Install-Web-Server/blog/main/tela.jpg)

### O que faz?
O `install` é um instalador de servidor web completo pra termux, podendo instalar e configurar o apache e phpmyadnin diretamente no ambiente termux sem o uso do duper-usuário (root).

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
> Para conseguir instalar o servidor web no ambiente termux, é necessário escolher as opçôes por ordem númerica


### Opçôes:
1. Instala todos os pacotes necessários para rodar o servidor web
2. Configura o apache para projetos
4. Configura o acesso ao painel do phpmyadmin
4. Sai do programa

### Recursos:
- [x] Hospedagem de projetos em /sdcard/htdocs
- [ ] URL Amigável em breve


@silva_olie :+1: Boa sorte! :shipit:
