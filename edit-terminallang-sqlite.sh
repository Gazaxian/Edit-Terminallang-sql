#!/bin/bash

# Caminho do banco de dados
db="$HOME/frases.db"

# Cores
BRANCO="\e[97m"
AZUL="\e[34m"
VERDE="\e[32m"
VERMELHO="\e[31m"
AMARELO="\e[33m"
RESET="\e[0m"

# Função para listar frases com paginação
listar_frases() {
    total=$(sqlite3 "$db" "SELECT COUNT(*) FROM frases;")
    limite=5
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
        echo -e "[N] Próxima página | [P] Página anterior | [Q] Sair"
        read -n 1 -s resposta
        case "$resposta" in
            n|N) [[ $pagina -lt $((total_paginas - 1)) ]] && ((pagina++)) ;;
            p|P) [[ $pagina -gt 0 ]] && ((pagina--)) ;;
            q|Q) clear; break ;;
        esac
    done
}

# Função para editar uma frase existente
editar_frase() {
    listar_frases
    echo -e "${AZUL}Digite o ID da frase que deseja editar:${RESET}"
    read id
    echo -e "${AZUL}Digite a nova versão da frase:${RESET}"
    read nova_frase
    sqlite3 "$db" "UPDATE frases SET frase = '$nova_frase' WHERE id = $id;"
    echo -e "${VERDE}✅ Frase editada com sucesso!${RESET}"
}

# Função para excluir uma frase
excluir_frase() {
    listar_frases
    echo -e "${AZUL}Digite o ID da frase que deseja excluir:${RESET}"
    read id
    sqlite3 "$db" "DELETE FROM frases WHERE id = $id;"
    echo -e "${VERMELHO}❌ Frase excluída com sucesso!${RESET}"
}

# Menu principal
while true; do
    echo -e "\n📚 ${BRANCO}Editor do Terminallang-SQLite${RESET}\n"
    echo -e "${AZUL}1) 📖 Listar frases${RESET}"
    echo -e "${AMARELO}2) ✍️ Editar frase${RESET}"
    echo -e "${VERMELHO}3) ❌ Excluir frase${RESET}"
    echo -e "${BRANCO}4) 🚪 Sair${RESET}"
    read -p "Escolha uma opção: " opcao
    
    case $opcao in
        1) listar_frases ;;
        2) editar_frase ;;
        3) excluir_frase ;;
        4) echo -e "${VERMELHO}Saindo...${RESET}"; exit 0 ;;
        *) echo -e "${VERMELHO}Opção inválida!${RESET}" ;;
    esac

done
