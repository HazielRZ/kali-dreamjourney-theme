#!/bin/bash

# ==============================================================================
# Script de Despliegue: Kali Dream Journey Theme
# Autor: Haziel Ruiz Zuñiga
# Descripción: Automatización de entorno XFCE con integración de Kitty y Fastfetch.
# ==============================================================================

set -e # Finalizar ejecución ante cualquier error

# Definición de variables de entorno
REPO_DIR=$(pwd)
CONFIG_DIR="$HOME/.config"
ICONS_DIR="$HOME/.icons"
WALLPAPER_DIR="$HOME/Imágenes/Wallpapers"
CURSOR_THEME_NAME="DreamJourney"
THEME_PATH="$CONFIG_DIR/kali-dreamjourney-theme"

echo "[*] Iniciando el despliegue del ecosistema visual Dream Journey..."

# 1. Gestión de Dependencias
echo "[*] Verificando e instalando dependencias (kitty, fastfetch, chafa)..."
sudo apt update && sudo apt install -y kitty fastfetch chafa curl

# 2. Preparación de la Estructura de Directorios
mkdir -p "$CONFIG_DIR/fastfetch"
mkdir -p "$CONFIG_DIR/kitty"
mkdir -p "$ICONS_DIR/$CURSOR_THEME_NAME/cursors" # <-- CORRECCIÓN: Subcarpeta añadida
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$THEME_PATH/assets"

# 3. Configuración del Tema de Cursores
echo "[*] Configurando el paquete de cursores..."
# CORRECCIÓN: Los archivos se copian a la subcarpeta cursors
cp -r "$REPO_DIR/cursors/"* "$ICONS_DIR/$CURSOR_THEME_NAME/cursors/"

# Generación dinámica del archivo index.theme en la raíz del tema
cat <<EOF > "$ICONS_DIR/$CURSOR_THEME_NAME/index.theme"
[Icon Theme]
Name=$CURSOR_THEME_NAME
Comment=Tema de cursores inspirado en Dream Journey
Inherits=core
EOF

chmod -R 755 "$ICONS_DIR/$CURSOR_THEME_NAME"


# 4. Migración de Archivos de Configuración y Assets
echo "[*] Desplegando archivos de configuración de sistema..."
cp "$REPO_DIR/config/fastfetch/config.jsonc" "$CONFIG_DIR/fastfetch/"
cp "$REPO_DIR/config/kitty/kitty.conf" "$CONFIG_DIR/kitty/"
cp "$REPO_DIR/assets/Logo.png" "$THEME_PATH/assets/"
cp "$REPO_DIR/wallpapers/Story_Still_still_090043083_00_(difference02).png" "$WALLPAPER_DIR/dream_journey.png"

# 5. Aplicación de Configuraciones en XFCE (xfconf)
echo "[*] Aplicando cambios en el registro de XFCE..."

# Establecer tema de cursores
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "$CURSOR_THEME_NAME"

# Aplicación del fondo de pantalla en todos los monitores detectados
for property in $(xfconf-query -c xfce4-desktop -p /backdrop -l | grep "last-image"); do
    xfconf-query -c xfce4-desktop -p "$property" -s "$WALLPAPER_DIR/dream_journey.png"
done

# 6. Configuración de Terminal Predeterminada
echo "[*] Estableciendo Kitty como emulador de terminal prioritario..."
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50
sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty

# 7. Persistencia en el Shell (zsh/bash)
if ! grep -q "fastfetch" "$HOME/.zshrc"; then
    echo -e "\n# Lanzamiento de Fastfetch\nfastfetch" >> "$HOME/.zshrc"
fi
echo "[*] Configurando el gestor de sesiones LightDM..."

# 1
sudo mkdir -p /usr/share/backgrounds
sudo cp "$WALLPAPER_DIR/dream_journey.png" /usr/share/backgrounds/dream_journey.png

# 2. Sobrescritura del archivo protegido mediante paso de parámetros con tee
sudo tee /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null <<EOF
[greeter]
background = /usr/share/backgrounds/dream_journey.png
theme-name = Adwaita-dark
icon-theme-name = $CURSOR_THEME_NAME
cursor-theme-name = $CURSOR_THEME_NAME
font-name = Monospace 11
indicators = ~host;~spacer;~clock;~spacer;~session;~power
EOF
echo "[+] El entorno se ha actualizado satisfactoriamente."
echo "[!] Nota: Es posible que deba cerrar y abrir su sesión para visualizar el cambio de cursores."
