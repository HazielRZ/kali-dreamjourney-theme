#!/bin/bash

# ==============================================================================
# Script de Instalación: Tema XFCE Dream Journey (Kali Linux)
# ==============================================================================

# Variables de entorno y rutas
REPO_DIR=$(pwd)
CONFIG_DIR="$HOME/.config"
ICONS_DIR="$HOME/.icons"
WALLPAPER_DIR="$HOME/Imágenes/Wallpapers"
WALLPAPER_FILE="dream_journey.jpg"
CURSOR_THEME_NAME="dream-journey-cursors"

echo "[*] Iniciando despliegue de arquitectura visual para XFCE..."

# 1. Instalación de dependencias del sistema
sudo apt update && sudo apt install -y fastfetch chafa

# 2. Estructuración del sistema de archivos local
mkdir -p "$CONFIG_DIR/fastfetch"
mkdir -p "$CONFIG_DIR/xfce4/terminal"
mkdir -p "$ICONS_DIR"
mkdir -p "$WALLPAPER_DIR"

# 3. Transferencia de assets y configuraciones
echo "[*] Migrando configuraciones locales..."
cp -r "$REPO_DIR/config/fastfetch/config.jsonc" "$CONFIG_DIR/fastfetch/"
cp -r "$REPO_DIR/config/xfce4-terminal/terminalrc" "$CONFIG_DIR/xfce4/terminal/"
cp -r "$REPO_DIR/cursors/$CURSOR_THEME_NAME" "$ICONS_DIR/"
cp "$REPO_DIR/wallpapers/$WALLPAPER_FILE" "$WALLPAPER_DIR/"

# 4. Inyección de configuración en el registro de XFCE
echo "[*] Aplicando modificaciones en xfconf..."

# Aplicación del paquete de cursores
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "$CURSOR_THEME_NAME"

# Aplicación del fondo de pantalla en todas las pantallas registradas
for property in $(xfconf-query -c xfce4-desktop -p /backdrop -l | grep "last-image"); do
    xfconf-query -c xfce4-desktop -p "$property" -s "$WALLPAPER_DIR/$WALLPAPER_FILE"
done

# 5. Integración del renderizado de sistema en la shell
if ! grep -q "fastfetch" "$HOME/.bashrc" && ! grep -q "fastfetch" "$HOME/.zshrc"; then
    echo "fastfetch" >> "$HOME/.zshrc" # Kali utiliza zsh por defecto en instalaciones recientes
fi

echo "[+] Despliegue completado con éxito. Se requiere reiniciar la sesión del emulador de terminal."
