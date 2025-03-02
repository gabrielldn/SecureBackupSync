# Exemplo de arquivo de configuração do SecureBackupSync

# Configurações de criptografia
# Defina GPG_RECIPIENT para usar criptografia com chave pública (GPG).
# Caso não seja definido, será utilizada criptografia simétrica com ENCRYPTION_PASSWORD.
# Para criptografia OpenSSL, ENCRYPTION_PASSWORD deve estar definido.
GPG_RECIPIENT=""         # Exemplo: "usuario@example.com"
ENCRYPTION_PASSWORD=""   # Senha para criptografia (GPG simétrico ou OpenSSL)

# Configurações do Minio
MINIO_ENDPOINT=""        # URL do servidor Minio (ex: "http://localhost:9000")
MINIO_ACCESS_KEY=""      # Chave de acesso (Access Key) do Minio
MINIO_SECRET_KEY=""      # Chave secreta (Secret Key) do Minio
MINIO_BUCKET=""          # Nome do bucket de destino no Minio

# Configurações do Google Drive (usando ferramenta 'gdrive')
GDRIVE_FOLDER_ID=""      # ID da pasta de destino no Google Drive (deixe vazio para pasta padrão do Drive)

# Configurações do AWS S3
AWS_S3_BUCKET=""         # Nome do bucket S3 de destino
AWS_REGION=""            # Região do bucket S3 (ex: "us-east-1")
AWS_ACCESS_KEY=""        # Chave de acesso AWS
AWS_SECRET_KEY=""        # Chave secreta AWS

# Configurações de SCP (Servidor remoto)
SCP_USER=""              # Usuário para conexão SSH
SCP_HOST=""              # Host ou IP do servidor
SCP_PORT="22"            # Porta SSH (padrão 22)
SCP_REMOTE_PATH=""       # Caminho de destino no servidor (ex: "/caminho/para/backup/")
SCP_SSH_KEY=""           # Caminho para chave SSH privada (se vazio, usar autenticação por senha)

# Configurações de notificação
DISCORD_WEBHOOK_URL=""     # URL do webhook do DISCORD para notificações de backup
EMAIL_TO=""              # Endereço de email para enviar notificação de backup