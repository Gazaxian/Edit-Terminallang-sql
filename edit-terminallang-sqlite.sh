#!/bin/bash

# Caminho do banco de dados (Usando variável de ambiente)
db="${DB_PATH:-$HOME/frases.db}"

# Verifica se o banco de dados existe
if [ ! -f "$db" ]; then
    echo -e "${VERMELHO}❌ Banco de dados não encontrado! Verifique o caminho.${RESET}"
    exit 1
fi

# Verifica se a tabela 'frases' existe
tabela=$(sqlite3 "$db" "SELECT name FROM sqlite_master WHERE type='table' AND name='frases';")
if [ "$tabela" != "frases" ]; then
    echo -e "${VERMELHO}❌ A tabela 'frases' não existe no banco de dados.${RESET}"
    exit 1
fi

# Cores
BRANCO="\e[97m"
AZUL="\e[34m"
VERDE="\e[32m"
VERMELHO="\e[31m"
AMARELO="\e[33m"
RESET="\e[0m"

# Limite de frases por página (valor padrão)
limite=5

# Função para validar entradas numéricas
validar_numero() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Função para escapar caracteres especiais (SQL Injection)
escapar() {
    echo "$1" | sed "s/'/''/g"
}

# Função para listar frases com paginação
listar_frases() {
    total=$(sqlite3 "$db" "SELECT COUNT(*) FROM frases;")
    pagina=0
    total_paginas=$(( (total + limite - 1) / limite ))

    while true; do
        clear
        inicio=$((pagina * limite))
        
        frases=$(sqlite3 "$db" "SELECT id, frase FROM frases LIMIT $limite OFFSET $inicio;")
        echo -e "📖 ${BRANCO}Frases salvas:${RESET}\n"
        
        IFS="|"
        while read -r id frase; do
            echo -e "${BRANCO}[$id]${RESET} ${AZUL}$frase${RESET}"
            echo -e "----------------------------------"
        done <<< "$frases"
        
        echo -e "${AZUL}Página $((pagina + 1))/$total_paginas${RESET}"
        echo -e "[N] Próxima página | [P] Página anterior | [L] Alterar limite | [Q] Sair"
        read -n 1 -s resposta
        case "$resposta" in
            n|N) [[ $pagina -lt $((total_paginas - 1)) ]] && ((pagina++)) ;;
            p|P) [[ $pagina -gt 0 ]] && ((pagina--)) ;;
            q|Q) clear; break ;;
            l|L) alterar_limite ;;
        esac
    done
}

# Função para buscar frases com paginação
buscar_frase() {
    echo -e "${AZUL}Digite a palavra-chave para buscar uma frase:${RESET}"
    read palavra
    
    # Total de frases encontradas com a palavra-chave
    total=$(sqlite3 "$db" "SELECT COUNT(*) FROM frases WHERE frase LIKE '%$palavra%';")
    pagina=0
    total_paginas=$(( (total + limite - 1) / limite ))

    while true; do
        clear
        inicio=$((pagina * limite))
        
        frases=$(sqlite3 "$db" "SELECT id, frase FROM frases WHERE frase LIKE '%$palavra%' LIMIT $limite OFFSET $inicio;")
        
        if [[ -z "$frases" ]]; then
            echo -e "${VERMELHO}❌ Nenhuma frase encontrada com essa palavra-chave.${RESET}"
            return
        fi
        
        echo -e "📖 ${BRANCO}Frases encontradas:${RESET}\n"
        
        IFS="|"
        while read -r id frase; do
            echo -e "${BRANCO}[$id]${RESET} ${AZUL}$frase${RESET}"
            echo -e "----------------------------------"
        done <<< "$frases"
        
        echo -e "${AZUL}Página $((pagina + 1))/$total_paginas${RESET}"
        echo -e "[N] Próxima página | [P] Página anterior | [L] Alterar limite | [Q] Sair"
        read -n 1 -s resposta
        case "$resposta" in
            n|N) [[ $pagina -lt $((total_paginas - 1)) ]] && ((pagina++)) ;;
            p|P) [[ $pagina -gt 0 ]] && ((pagina--)) ;;
            q|Q) clear; break ;;
            l|L) alterar_limite ;;
        esac
    done
}

# Função para validar se o ID existe
validar_id() {
    id=$1
    # Verifica se o ID existe no banco de dados
    resultado=$(sqlite3 "$db" "SELECT COUNT(*) FROM frases WHERE id = $id;")
    if [[ $resultado -eq 0 ]]; then
        echo -e "${VERMELHO}❌ ID inválido! A frase com esse ID não existe.${RESET}"
        return 1
    fi
    return 0
}

# Função para editar uma frase existente
editar_frase() {
    listar_frases
    echo -e "${AZUL}Digite o ID da frase que deseja editar:${RESET}"
    read id
    if ! validar_id $id; then
        return
    fi
    echo -e "${AZUL}Digite a nova versão da frase:${RESET}"
    read nova_frase
    nova_frase=$(escapar "$nova_frase")
    sqlite3 "$db" "UPDATE frases SET frase = '$nova_frase' WHERE id = $id;"
    echo -e "${VERDE}✅ Frase editada com sucesso!${RESET}"
}

# Função para excluir uma frase
excluir_frase() {
    listar_frases
    echo -e "${AZUL}Digite o ID da frase que deseja excluir:${RESET}"
    read id
    if ! validar_id $id; then
        return
    fi
    sqlite3 "$db" "DELETE FROM frases WHERE id = $id;"
    echo -e "${VERMELHO}❌ Frase excluída com sucesso!${RESET}"
}

# Função para alterar o limite de frases por página
alterar_limite() {
    echo -e "${AZUL}Digite o novo limite de frases por página:${RESET}"
    read novo_limite
    if validar_numero "$novo_limite" && [ "$novo_limite" -gt 0 ]; then
        limite=$novo_limite
        echo -e "${VERDE}✅ Limite de frases por página alterado para $limite.${RESET}"
    else
        echo -e "${VERMELHO}❌ Limite inválido! O valor deve ser um número maior que zero.${RESET}"
    fi
}

# Menu principal
while true; do
    echo -e "\n📚 ${BRANCO}Editor do Terminallang-SQLite${RESET}\n"
    echo -e "${AZUL}1) 📖 Listar frases${RESET}"
    echo -e "${AMARELO}2) ✍️ Editar frase${RESET}"
    echo -e "${VERMELHO}3) ❌ Excluir frase${RESET}"
    echo -e "${VERDE}4) 🔍 Buscar frase${RESET}"
    echo -e "${BRANCO}5) 🚪 Sair${RESET}"
    read -p "Escolha uma opção: " opcao
    
    while ! [[ "$opcao" =~ ^[1-5]$ ]]; do
        echo -e "${VERMELHO}Opção inválida! Escolha entre 1 e 5.${RESET}"
        read -p "Escolha uma opção: " opcao
    done

    case $opcao in
        1) listar_frases ;;
        2) editar_frase ;;
        3) excluir_frase ;;
        4) buscar_frase ;;
        5) echo -e "${VERMELHO}Saindo...${RESET}"; exit 0 ;;
    esac
done
