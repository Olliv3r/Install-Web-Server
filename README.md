# TAMP Server - Termux Web Server Installer

<div align="center">
  
![TAMP Server Logo](https://github.com/Olliv3r/Install-Web-Server/blob/main/assets/tamp.png)

**TAMP** (Termux + Apache + MySQL + PHP) - Servidor web completo para Termux

[![GitHub stars](https://img.shields.io/github/stars/Olliv3r/Install-Web-Server.svg)](https://github.com/Olliv3r/Install-Web-Web-Server/stargazers)
[![GitHub license](https://img.shields.io/github/license/Olliv3r/Install-Web-Server)](https://github.com/Olliv3r/Install-Web-Server/blob/main/LICENSE)

</div>

## 📋 Sobre o Projeto

O **Install Web Server** é um script automatizado que instala e configura um ambiente de desenvolvimento web completo no Termux - TAMP Server, sem necessidade de acesso root.

### 🛠️ Componentes Instalados

- **Apache 2** - Servidor web
- **PHP 8.x** - Linguagem de programação
- **MariaDB** - Banco de dados
- **phpMyAdmin** - Gerenciador web do MySQL/MariaDB
- **Ferramentas auxiliares** - Git, curl, wget, etc.

## ⚡ Instalação Rápida

### Pré-requisitos
- Termux instalado
- Conexão com internet
- Armazenamento externo habilitado

### Passo a Passo

1. **Instalar o Git:**
```bash
apt update && apt upgrade -y
apt install git -y
```

1. Clonar o repositório:

```bash
git clone https://github.com/Olliv3r/Install-Web-Server.git
cd Install-Web-Server
```

1. Executar o instalador:

```bash
bash install.sh
```

🎯 Como Usar

📝 Instalação Sequencial (OBRIGATÓRIO)

Siga exatamente esta ordem no menu do script:

1. Opção 1 - Instalar pacotes necessários
2. Opção 2 - Configurar Apache
3. Opção 3 - Configurar phpMyAdmin (Opcional)

🖥️ Menu do Script

```
[1] 📦 Instalar pacotes necessários
[2] ⚙️  Configurar Apache para projetos
[3] 🗃️  Configurar phpMyAdmin (Opcional)
[4] 🗑️  Desinstalar todos os pacotes
[5] 🗑  Limpar arquivos (Opcional)
[6] 🚪 Sair do programa
```

🗂️ Estrutura do Projeto

Após a instalação, sua estrutura será:

```
/sdcard/htdocs/                 # Pasta principal dos projetos
├── index.php                   # Painel de controle
├── .htaccess                 	# Arquivo de configuração
├── projeto1/                   # Seus projetos PHP
├── projeto2/
└── ...
```

🌐 Acesso Web

- Painel Principal: http://localhost:8080
- phpMyAdmin: http://localhost:8080/phpmyadmin
- Seus Projetos: http://localhost:8080/nome-do-projeto

⚙️ Gerenciamento de Serviços

TAMP Server:

```
# Iniciar
tamp-start

# Parar
tamp-stop

# Ver status
tamp-status
```

### 🔧 Configurações Especiais

URL Amigável (mod_rewrite):
- Habilitado automaticamente para todos os projetos.

Diretório Personalizado:
- Projetos armazenados em /sdcard/htdocs/ para fácil acesso.

Permissões:
- Configuradas automaticamente para funcionar sem root.

### 🗑️ Desinstalação:

Para remover completamente:

1. Execute o script: bash install.sh
2. Selecione a Opção 4 - Desinstalar pacotes
3. Confirme a desinstalação

### ❗ Solução de Problemas

Apache não inicia:

```bash
# Verificar erro
apachectl configtest

# Ver portas em uso
netstat -tulpn
```

MariaDB não conecta:

```bash
# Verificar se está rodando
ps aux | grep mariadbd

# Tentar iniciar manualmente
mariadbd-safe -u $(whoami) &

# Testar conexão
mysql -u root -h 127.0.0.1
```

Permissão negada:

```bash
# Dar permissão à pasta htdocs
chmod 755 /sdcard/htdocs
chmod 644 /sdcard/htdocs/*.php
```

### Screenshot
Painel do servidor:

![Servidor em Ação](https://github.com/Olliv3r/Install-Web-Server/blob/main/assets/server.jpg)

### 🎁 Recursos Incluídos

- [x] Hospedagem local de projetos PHP
- [x] Painel phpMyAdmin integrado
- [x] URL amigável habilitada
- [x] Configuração automática do Apache
- [x] Script de desinstalação completo
- [x] Interface colorida e amigável
- [x] Suporte a MariaDB nativo
- [ ] Em breve

### 📞 Suporte

Encontrou problemas?

1. Verifique se seguiu a ordem correta de instalação
2. Confirme que todos os pacotes foram instalados
3. Execute o script novamente para reinstalação

Autor: Olliv3r
Contribuições: São bem-vindas! 😊

---

⭐ Dê uma estrela no repositório se este projeto te ajudou!

```

## 🚀 **Principais melhorias:**

### 1. **Estrutura mais organizada**
- Seções claras e bem divididas
- Ícones visuais para melhor navegação
- Hierarquia lógica de informações

### 2. **Instruções mais claras**
- Passo a passo numerado e objetivo
- Destaque para a ordem obrigatória de instalação
- Comandos bem formatados

### 3. **Informações técnicas úteis**
- Estrutura de pastas após instalação
- URLs de acesso
- Comandos de gerenciamento completos

### 4. **Solução de problemas**
- Seção dedicada a problemas comuns
- Comandos de diagnóstico
- Soluções passo a passo

### 5. **Design mais profissional**
- Uso de emojis para categorização visual
- Formatação consistente de código
- Destaques importantes

### 6. **Melhor SEO e leitura**
- Títulos descritivos
- Listas organizadas
- Linguagem clara e direta
