#!/bin/bash
if [ -f "$(dirname "$0")/config.sh" ]; then
    source "$(dirname "$0")/config.sh"
else
    echo "Arquivo de configuração config.sh não encontrado. Por favor copie config.example.sh para config.sh e ajuste as variáveis." >&2
    exit 1
fi

# Carrega bibliotecas
source "$(dirname "$0")/libs/encrypt.sh"
source "$(dirname "$0")/libs/upload.sh"

# Garante que o diretório de logs existe
mkdir -p "$(dirname "$0")/logs"

LOG_FILE="$(dirname "$0")/logs/backup_$(date +%Y%m%d%H%M%S).log"

echo "SecureBackupSync - Backup Interativo"
echo "Iniciando backup em $(date)" >> "$LOG_FILE"

# Solicita o diretório de origem do backup
read -rp "Digite o caminho da pasta que deseja fazer backup: " SOURCE_DIR
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Erro: diretório não encontrado." | tee -a "$LOG_FILE"
    exit 1
fi

# Cria o arquivo TAR comprimido
BASENAME=$(basename "$SOURCE_DIR")
TIMESTAMP=$(date +%Y%m%d%H%M%S)
TAR_FILE="/tmp/${BASENAME}_${TIMESTAMP}.tar.gz"

echo "Compactando a pasta $SOURCE_DIR..." | tee -a "$LOG_FILE"
tar -czf "$TAR_FILE" -C "$(dirname "$SOURCE_DIR")" "$BASENAME" 2>> "$LOG_FILE"
if [ $? -ne 0 ]; then
    echo "Erro ao criar arquivo TAR." | tee -a "$LOG_FILE"
    exit 1
fi
echo "Arquivo TAR criado: $TAR_FILE" | tee -a "$LOG_FILE"

# Escolhe o método de criptografia
echo "Selecione o método de criptografia:"
echo "1) GPG"
echo "2) OpenSSL"
read -rp "Escolha [1-2]: " ENC_METHOD
ENCRYPTED_FILE="$TAR_FILE"
if [ "$ENC_METHOD" == "1" ]; then
    ENCRYPTED_FILE="${TAR_FILE}.gpg"
    echo "Criptografando o arquivo com GPG..." | tee -a "$LOG_FILE"
    encrypt_gpg "$TAR_FILE" "$ENCRYPTED_FILE" 2>> "$LOG_FILE"
elif [ "$ENC_METHOD" == "2" ]; then
    ENCRYPTED_FILE="${TAR_FILE}.enc"
    echo "Criptografando o arquivo com OpenSSL..." | tee -a "$LOG_FILE"
    encrypt_openssl "$TAR_FILE" "$ENCRYPTED_FILE" 2>> "$LOG_FILE"
else
    echo "Método de criptografia inválido. Saindo." | tee -a "$LOG_FILE"
    exit 1
fi

# Verifica se a criptografia foi bem sucedida
if [ $? -ne 0 ]; then
    echo "Erro durante a criptografia." | tee -a "$LOG_FILE"
    echo "Backup não criptografado mantido em: $TAR_FILE (remova-o manualmente se não for necessário)." | tee -a "$LOG_FILE"
    exit 1
fi

# Remove arquivo TAR original após criptografia bem sucedida
rm -f "$TAR_FILE"
echo "Arquivo criptografado: $ENCRYPTED_FILE" | tee -a "$LOG_FILE"

# Escolhe o destino do backup
echo "Selecione o destino do backup:"
echo "1) Minio"
echo "2) Google Drive"
echo "3) AWS S3"
echo "4) SCP (Servidor Remoto via SCP)"
read -rp "Escolha [1-4]: " DEST_CHOICE

UPLOAD_RESULT=0
case "$DEST_CHOICE" in
    1)
        echo "Enviando para Minio..." | tee -a "$LOG_FILE"
        upload_minio "$ENCRYPTED_FILE" 2>> "$LOG_FILE" || UPLOAD_RESULT=$?
        ;;
    2)
        echo "Enviando para Google Drive..." | tee -a "$LOG_FILE"
        upload_gdrive "$ENCRYPTED_FILE" 2>> "$LOG_FILE" || UPLOAD_RESULT=$?
        ;;
    3)
        echo "Enviando para AWS S3..." | tee -a "$LOG_FILE"
        upload_s3 "$ENCRYPTED_FILE" 2>> "$LOG_FILE" || UPLOAD_RESULT=$?
        ;;
    4)
        echo "Enviando via SCP..." | tee -a "$LOG_FILE"
        upload_scp "$ENCRYPTED_FILE" 2>> "$LOG_FILE" || UPLOAD_RESULT=$?
        ;;
    *)
        echo "Destino inválido. Saindo." | tee -a "$LOG_FILE"
        UPLOAD_RESULT=1
        ;;
esac

if [ $UPLOAD_RESULT -ne 0 ]; then
    echo "Erro durante o upload do backup." | tee -a "$LOG_FILE"
else
    echo "Upload concluído com sucesso." | tee -a "$LOG_FILE"
fi

# Notificações via Slack ou email
if [ $UPLOAD_RESULT -eq 0 ]; then
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        SLACK_MESSAGE="Backup de $SOURCE_DIR concluído com sucesso em $(date). Destino: $DEST_CHOICE."
        curl -s -X POST -H 'Content-type: application/json' --data "{\"text\":\"$SLACK_MESSAGE\"}" "$SLACK_WEBHOOK_URL" >> "$LOG_FILE" 2>&1
    fi
    if [ -n "$EMAIL_TO" ]; then
        SUBJECT="Backup Concluído - $BASENAME"
        BODY="O backup da pasta $SOURCE_DIR foi concluído com sucesso em $(date) e enviado para o destino selecionado."
        echo "$BODY" | mail -s "$SUBJECT" "$EMAIL_TO"
    fi
    echo "Notificação de conclusão enviada." | tee -a "$LOG_FILE"
else
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        SLACK_MESSAGE="Backup de $SOURCE_DIR falhou em $(date)."
        curl -s -X POST -H 'Content-type: application/json' --data "{\"text\":\"$SLACK_MESSAGE\"}" "$SLACK_WEBHOOK_URL" >> "$LOG_FILE" 2>&1
    fi
    if [ -n "$EMAIL_TO" ]; then
        SUBJECT="Falha no Backup - $BASENAME"
        BODY="O backup da pasta $SOURCE_DIR falhou em $(date). Verifique os logs para mais detalhes."
        echo "$BODY" | mail -s "$SUBJECT" "$EMAIL_TO"
    fi
    echo "Notificação de falha enviada." | tee -a "$LOG_FILE"
fi

# Remove arquivo criptografado local após upload bem-sucedido
if [ $UPLOAD_RESULT -eq 0 ]; then
    rm -f "$ENCRYPTED_FILE"
    echo "Arquivo local $ENCRYPTED_FILE removido após envio." >> "$LOG_FILE"
fi

exit $UPLOAD_RESULT
