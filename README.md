# SecureBackupSync

SecureBackupSync é um script de backup interativo via linha de comando (CLI) que permite criar backups de diretórios locais, criptografá-los e enviá-los para diversos destinos de armazenamento, como Minio, Google Drive, AWS S3 ou um servidor remoto via SCP.

## Funcionalidades

- **Backup interativo**: O script `backup.sh` pergunta ao usuário qual diretório deseja fazer backup e para onde enviá-lo.
- **Compactação e criptografia**: O diretório selecionado é compactado em um arquivo `.tar.gz` e, em seguida, criptografado usando GPG (criptografia assimétrica ou simétrica) ou OpenSSL (criptografia simétrica AES-256).
- **Múltiplos destinos**: Suporta envio do backup para:
  - **Minio** (armazenamento compatível com S3)
  - **Google Drive**
  - **AWS S3**
  - **Servidor remoto via SCP**
- **Logs detalhados**: Todas as operações são registradas em arquivos de log no diretório `logs/`.
- **Notificações**: Opcionalmente, envia notificação via Slack ou e-mail após a conclusão (ou falha) do backup.

## Pré-requisitos

Antes de usar o SecureBackupSync, certifique-se de ter instalado/configurado:
- **Bash**: O script utiliza Bash e utilitários padrão do Unix (`tar`, etc.).
- **GPG** (opcional): Necessário para criptografia GPG. Configure uma chave GPG ou prepare uma senha para criptografia simétrica.
- **OpenSSL** (opcional): Necessário para criptografia via OpenSSL.
- **Cliente AWS CLI** (opcional): Necessário para enviar para AWS S3 ou Minio. Configure as credenciais no arquivo de configuração ou no seu ambiente.
- **Ferramenta Google Drive CLI** (opcional): Por exemplo, a ferramenta [`gdrive`](https://github.com/prasmussen/gdrive) para enviar arquivos ao Google Drive. Certifique-se de autenticá-la antes do uso.
- **Acesso SSH** (opcional): Para enviar via SCP, é necessário ter acesso SSH ao servidor de destino (configurar usuário, host, porta e chave ou senha).
- **Utilitário de e-mail** (opcional): Para notificações por e-mail, configure o comando `mail` ou similar no sistema, ou ajuste o script para usar seu método preferido de envio de email.
- **cURL**: Necessário para envio de notificações via webhook do Slack.

## Configuração

1. Faça uma cópia do arquivo `config.example.sh` e renomeie para `config.sh`.
2. Edite o arquivo `config.sh` com as informações apropriadas:
   - Defina as credenciais e configurações para os destinos que planeja usar (Minio, Google Drive, AWS S3, SCP).
   - Forneça a senha de criptografia (`ENCRYPTION_PASSWORD`) e/ou o destinatário GPG (`GPG_RECIPIENT`) para a criptografia.
   - Configure a URL do webhook do Slack (`SLACK_WEBHOOK_URL`) e/ou o email de destino (`EMAIL_TO`) para notificações, se desejar.
3. Certifique-se de deixar o script principal executável: `chmod +x backup.sh`.

## Uso

Para iniciar o backup, execute o script principal no terminal:
