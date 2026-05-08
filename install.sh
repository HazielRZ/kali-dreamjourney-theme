#!/bin/bash

# Definición de rutas
REPO_DIR=$(pwd)
CONFIG_DIR="$HOME/.config"

echo "[*] Iniciando la instalación del tema Dream Journey..."

# 1. Instalación de dependencias 
echo "[*] Instalando dependencias necesarias (fastfetch, feh)..."
sudo apt update && sudo apt install -y fastfetch feh kitty

# 2. Creación de directorios
mkdir -p "$CONFIG_DIR/fastfetch"
mkdir -p "$CONFIG_DIR/kitty"
mkdir -p "$HOME/Imágenes/Wallpapers"

# 3. Aplicación de configuraciones
echo "[*] Copiando archivos de configuración..."
cp -r "$REPO_DIR/config/fastfetch/config.jsonc" "$CONFIG_DIR/fastfetch/"
cp -r "$REPO_DIR/config/kitty/kitty.conf" "$CONFIG_DIR/kitty/"

# Copiar recursos gráficos
cp "$REPO_DIR/wallpapers/"* "$HOME/Imágenes/Wallpapers/"
cp -r "$REPO_DIR/assets" "$CONFIG_DIR/kali-dreamjourney-theme/"

# 4. Aplicación del fondo de pantalla
echo "[*] Estableciendo fondo de pantalla..."
feh --bg-fill "$HOME/Imágenes/Wallpapers/dream_journey.jpg"

# Añadir feh al inicio automático (ejemplo para .xinitrc o bspwmrc)
if ! grep -q "feh --bg-fill" "$HOME/.xprofile"; then
    echo "feh --bg-fill $HOME/Imágenes/Wallpapers/dream_journey.jpg &" >> "$HOME/.xprofile"
fi

# 5. Configurar el bashrc para ejecutar fastfetch al abrir la terminal
if ! grep -q "fastfetch" "$HOME/.bashrc"; then
    echo "fastfetch" >> "$HOME/.bashrc"
fi

echo "[+] Instalación completada. Por favor, reinicie su terminal."
