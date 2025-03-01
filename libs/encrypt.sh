#!/bin/bash
# Funções para criptografia de arquivos

# Criptografa um arquivo utilizando GPG.
# Usa criptografia assimétrica se GPG_RECIPIENT estiver configurado, caso contrário usa criptografia simétrica com ENCRYPTION_PASSWORD.
encrypt_gpg() {
    local input_file="$1"
    local output_file="$2"
    if [ -z "$input_file" ] || [ -z "$output_file" ]; then
        echo "Uso: encrypt_gpg <arquivo_entrada> <arquivo_saida>" >&2
        return 1
    fi

    if [ -n "$GPG_RECIPIENT" ]; then
        # Criptografia assimétrica com chave pública
        gpg --yes --encrypt --recipient "$GPG_RECIPIENT" --output "$output_file" "$input_file"
    else
        # Criptografia simétrica com senha
        if [ -z "$ENCRYPTION_PASSWORD" ]; then
            echo "Nenhuma senha definida para criptografia simétrica." >&2
            return 1
        fi
        gpg --yes --batch --passphrase "$ENCRYPTION_PASSWORD" -c --output "$output_file" "$input_file"
    fi
}

# Criptografa um arquivo utilizando OpenSSL (AES-256-CBC).
encrypt_openssl() {
    local input_file="$1"
    local output_file="$2"
    if [ -z "$input_file" ] || [ -z "$output_file" ]; then
        echo "Uso: encrypt_openssl <arquivo_entrada> <arquivo_saida>" >&2
        return 1
    fi

    if [ -z "$ENCRYPTION_PASSWORD" ]; then
        echo "Nenhuma senha definida para criptografia OpenSSL." >&2
        return 1
    fi

    openssl enc -aes-256-cbc -salt -pbkdf2 -in "$input_file" -out "$output_file" -k "$ENCRYPTION_PASSWORD"
}
