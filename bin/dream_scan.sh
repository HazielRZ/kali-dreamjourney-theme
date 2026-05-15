#!/bin/bash

# ==============================================================================
# Motor de Escaneo Estilizado (Nmap Wrapper)
# Objetivo: Identificación de topología y análisis de puertos
# ==============================================================================

# Definición de Códigos ANSI True Color (Paleta Dream Journey)
C_GOLD="\e[38;2;242;210;46m"
C_CREAM="\e[38;2;242;224;208m"
C_ROSE="\e[38;2;115;93;99m"
C_BG="\e[48;2;13;13;13m"
C_RESET="\e[0m"

# Validación de argumentos
if [ -z "$1" ]; then
    echo -e "${C_ROSE}[!] Uso: dream_scan <IP_o_Rango> (Ej. 192.168.1.0/24)${C_RESET}"
    exit 1
fi

TARGET=$1

# Renderizado de Cabecera
clear
echo -e "${C_GOLD}╭──────────────────────────────────────────────────────────╮${C_RESET}"
echo -e "${C_GOLD}│  ${C_CREAM}ANALIZADOR TOPOLÓGICO Y DE SERVICIOS (UNIDAD 6)         ${C_GOLD}│${C_RESET}"
echo -e "${C_GOLD}│  ${C_ROSE}Objetivo: ${TARGET}                                   ${C_GOLD}│${C_RESET}"
echo -e "${C_GOLD}╰──────────────────────────────────────────────────────────╯${C_RESET}"
echo -e "${C_ROSE}[*] Inicializando motor Nmap. Interceptando flujo de datos...${C_RESET}\n"

# Ejecución de Nmap entubada a AWK para inyección cromática
nmap -sV -T4 -Pn "$TARGET" | awk \
    -v gold="$C_GOLD" \
    -v cream="$C_CREAM" \
    -v rose="$C_ROSE" \
    -v rst="$C_RESET" '
{
    # Resaltado de puertos abiertos y protocolos
    if ($0 ~ /^[0-9]+\/(tcp|udp)/) {
        if ($2 == "open") {
            # Puerto y estado en Dorado, Servicio en Crema
            printf "%s%-10s%s %s%-10s%s %s%s%s\n", cream, $1, rst, gold, $2, rst, cream, substr($0, index($0,$3)), rst
        } else {
            # Puertos filtrados o cerrados en Rosa oscuro
            printf "%s%s%s\n", rose, $0, rst
        }
    }
    # Resaltado de Direcciones IP descubiertas
    else if ($0 ~ /Nmap scan report for/) {
        printf "\n%s%s%s\n", gold, $0, rst
    }
    # Resaltado de Cabeceras de tabla
    else if ($0 ~ /^PORT/) {
        printf "%s%s%s\n", rose, $0, rst
    }
    # Direccionamiento MAC
    else if ($0 ~ /^MAC Address:/) {
        printf "%s%s%s\n", cream, $0, rst
    }
    # Resto del texto
    else {
        printf "%s%s%s\n", rose, $0, rst
    }
}'

echo -e "\n${C_GOLD}[+] Secuencia de análisis finalizada.${C_RESET}"
