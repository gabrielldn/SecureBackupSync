#!/bin/bash
# Funções para upload para destinos diferentes

# Envia um arquivo para um bucket Minio (compatível com S3).
upload_minio() {
    local file="$1"
    if [ -z "$file" ]; then
        echo "Uso: upload_minio <arquivo>" >&2
        return 1
    fi
    if [ -z "$MINIO_ENDPOINT" ] || [ -z "$MINIO_ACCESS_KEY" ] || [ -z "$MINIO_SECRET_KEY" ] || [ -z "$MINIO_BUCKET" ]; then
        echo "Configurações do Minio incompletas." >&2
        return 1
    fi
    if ! command -v aws >/dev/null 2>&1; then
        echo "AWS CLI não encontrado. Instale para usar o upload Minio." >&2
        return 1
    fi
    AWS_ACCESS_KEY_ID="$MINIO_ACCESS_KEY" AWS_SECRET_ACCESS_KEY="$MINIO_SECRET_KEY" \
      aws --endpoint-url "$MINIO_ENDPOINT" s3 cp "$file" "s3://$MINIO_BUCKET/$(basename "$file")"
}

# Envia um arquivo para o Google Drive utilizando a ferramenta gdrive.
upload_gdrive() {
    local file="$1"
    if [ -z "$file" ]; then
        echo "Uso: upload_gdrive <arquivo>" >&2
        return 1
    fi
    if ! command -v gdrive >/dev/null 2>&1; then
        echo "Ferramenta gdrive não encontrada. Instale 'gdrive' para usar este recurso." >&2
        return 1
    fi
    if [ -n "$GDRIVE_FOLDER_ID" ]; then
        gdrive upload --parent "$GDRIVE_FOLDER_ID" "$file"
    else
        gdrive upload "$file"
    fi
}

# Envia um arquivo para um bucket AWS S3.
upload_s3() {
    local file="$1"
    if [ -z "$file" ]; then
        echo "Uso: upload_s3 <arquivo>" >&2
        return 1
    fi
    if [ -z "$AWS_S3_BUCKET" ]; then
        echo "Bucket S3 não configurado." >&2
        return 1
    fi
    if ! command -v aws >/dev/null 2>&1; then
        echo "AWS CLI não encontrado. Instale para usar o upload S3." >&2
        return 1
    fi
    AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY" AWS_SECRET_ACCESS_KEY="$AWS_SECRET_KEY" \
      aws s3 cp "$file" "s3://$AWS_S3_BUCKET/$(basename "$file")" --region "${AWS_REGION:-us-east-1}"
}

# Envia um arquivo para um servidor remoto via SCP.
upload_scp() {
    local file="$1"
    if [ -z "$file" ]; then
        echo "Uso: upload_scp <arquivo>" >&2
        return 1
    fi
    if [ -z "$SCP_USER" ] || [ -z "$SCP_HOST" ] || [ -z "$SCP_REMOTE_PATH" ]; then
        echo "Configurações SCP incompletas." >&2
        return 1
    fi
    if [ -n "$SCP_SSH_KEY" ]; then
        scp -i "$SCP_SSH_KEY" -P "${SCP_PORT:-22}" "$file" "$SCP_USER@$SCP_HOST:$SCP_REMOTE_PATH"
    else
        scp -P "${SCP_PORT:-22}" "$file" "$SCP_USER@$SCP_HOST:$SCP_REMOTE_PATH"
    fi
}
