#!/bin/bash
# Funções para upload para destinos diferentes com tratamento de erros detalhado

# Envia um arquivo para um bucket Minio (compatível com S3).
upload_minio() {
    local file="$1"
    if [ -z "$file" ]; then
        echo "Erro: arquivo não especificado." >&2
        echo "Uso: upload_minio <arquivo>" >&2
        return 1
    fi

    # Verifica as variáveis de ambiente necessárias
    local missing_vars=()
    [ -z "$MINIO_ENDPOINT" ] && missing_vars+=("MINIO_ENDPOINT")
    [ -z "$MINIO_ACCESS_KEY" ] && missing_vars+=("MINIO_ACCESS_KEY")
    [ -z "$MINIO_SECRET_KEY" ] && missing_vars+=("MINIO_SECRET_KEY")
    [ -z "$MINIO_BUCKET" ] && missing_vars+=("MINIO_BUCKET")
    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo "Erro: As seguintes variáveis estão ausentes: ${missing_vars[*]}" >&2
        return 1
    fi

    # Verifica se AWS CLI está instalado
    local aws_path
    if ! aws_path=$(command -v aws 2>&1); then
        echo "Erro: AWS CLI não encontrado." >&2
        echo "Detalhes do comando 'command -v aws': $aws_path" >&2
        return 1
    fi

    # Tenta enviar o arquivo e captura a saída
    local output
    output=$(AWS_ACCESS_KEY_ID="$MINIO_ACCESS_KEY" AWS_SECRET_ACCESS_KEY="$MINIO_SECRET_KEY" \
        aws --endpoint-url "$MINIO_ENDPOINT" s3 cp "$file" "s3://$MINIO_BUCKET/$(basename "$file")" 2>&1)
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "Erro ao executar AWS CLI para upload Minio. Código de erro: $exit_code" >&2
        echo "Comando executado:" >&2
        echo "  AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... aws --endpoint-url $MINIO_ENDPOINT s3 cp $file s3://$MINIO_BUCKET/$(basename "$file")" >&2
        echo "Saída do comando:" >&2
        echo "----------------------------------------" >&2
        echo "$output" | sed 's/^/    /' >&2
        echo "----------------------------------------" >&2
        return $exit_code
    fi
}

upload_gdrive() {
    local file="$1"
    if [ -z "$file" ]; then
        echo "Erro: arquivo não especificado." >&2
        echo "Uso: upload_gdrive <arquivo>" >&2
        return 1
    fi

    # Verifica se gdrive está instalado
    local gdrive_path
    if ! gdrive_path=$(command -v gdrive 2>&1); then
        echo "Erro: Ferramenta gdrive não encontrada." >&2
        echo "Detalhes do comando 'command -v gdrive': $gdrive_path" >&2
        return 1
    fi

    local cmd_base="gdrive files upload"

    if [ -n "$GDRIVE_FOLDER_ID" ]; then
        cmd_base+=" --parent $GDRIVE_FOLDER_ID"
    fi

    # Executa o comando de upload e captura a saída
    local output
    output=$($cmd_base "$file" 2>&1)
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "Erro ao executar gdrive files upload. Código de erro: $exit_code" >&2
        echo "Comando executado:" >&2
        echo "  $cmd_base $file" >&2
        echo "Saída do comando:" >&2
        echo "----------------------------------------" >&2
        echo "$output" | sed 's/^/    /' >&2
        echo "----------------------------------------" >&2
        return $exit_code
    fi
}


# Envia um arquivo para um bucket AWS S3.
upload_s3() {
    local file="$1"
    if [ -z "$file" ]; then
        echo "Erro: arquivo não especificado." >&2
        echo "Uso: upload_s3 <arquivo>" >&2
        return 1
    fi

    if [ -z "$AWS_S3_BUCKET" ]; then
        echo "Erro: Bucket S3 não configurado. (Variável AWS_S3_BUCKET ausente)" >&2
        return 1
    fi

    # Verifica se AWS CLI está instalado
    local aws_path
    if ! aws_path=$(command -v aws 2>&1); then
        echo "Erro: AWS CLI não encontrado." >&2
        echo "Detalhes do comando 'command -v aws': $aws_path" >&2
        return 1
    fi

    # Tenta fazer o upload e captura a saída
    local output
    output=$(AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY" AWS_SECRET_ACCESS_KEY="$AWS_SECRET_KEY" \
        aws s3 cp "$file" "s3://$AWS_S3_BUCKET/$(basename "$file")" --region "${AWS_REGION:-us-east-1}" 2>&1)
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "Erro ao executar AWS CLI para upload S3. Código de erro: $exit_code" >&2
        echo "Comando executado:" >&2
        echo "  AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... aws s3 cp $file s3://$AWS_S3_BUCKET/$(basename "$file") --region ${AWS_REGION:-us-east-1}" >&2
        echo "Saída do comando:" >&2
        echo "----------------------------------------" >&2
        echo "$output" | sed 's/^/    /' >&2
        echo "----------------------------------------" >&2
        return $exit_code
    fi
}

# Envia um arquivo para um servidor remoto via SCP.
upload_scp() {
    local file="$1"
    if [ -z "$file" ]; then
        echo "Erro: arquivo não especificado." >&2
        echo "Uso: upload_scp <arquivo>" >&2
        return 1
    fi

    # Verifica as variáveis necessárias para SCP
    local missing_vars=()
    [ -z "$SCP_USER" ] && missing_vars+=("SCP_USER")
    [ -z "$SCP_HOST" ] && missing_vars+=("SCP_HOST")
    [ -z "$SCP_REMOTE_PATH" ] && missing_vars+=("SCP_REMOTE_PATH")
    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo "Erro: As seguintes variáveis necessárias para SCP estão ausentes: ${missing_vars[*]}" >&2
        return 1
    fi

    # Define o comando SCP com ou sem chave SSH
    local scp_cmd
    if [ -n "$SCP_SSH_KEY" ]; then
        scp_cmd="scp -i $SCP_SSH_KEY -P ${SCP_PORT:-22}"
    else
        scp_cmd="scp -P ${SCP_PORT:-22}"
    fi

    # Tenta fazer o upload e captura a saída
    local output
    output=$($scp_cmd "$file" "$SCP_USER@$SCP_HOST:$SCP_REMOTE_PATH" 2>&1)
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "Erro ao executar SCP para upload. Código de erro: $exit_code" >&2
        echo "Comando executado:" >&2
        echo "  $scp_cmd $file $SCP_USER@$SCP_HOST:$SCP_REMOTE_PATH" >&2
        echo "Saída do comando:" >&2
        echo "----------------------------------------" >&2
        echo "$output" | sed 's/^/    /' >&2
        echo "----------------------------------------" >&2
        return $exit_code
    fi
}
