#!/bin/bash

# ==============================================================================
# Script de Despliegue: Kali Dream Journey Theme (V3 - Full Stack)
# Autor: Haziel Ruiz Zuñiga
# Descripción: Automatización total de XFCE, Kitty, GTK3 y gestor LightDM.
# ==============================================================================

set -e 

# Definición de variables de entorno
REPO_DIR=$(pwd)
CONFIG_DIR="$HOME/.config"
ICONS_DIR="$HOME/.icons"
WALLPAPER_DIR="$HOME/Imágenes/Wallpapers"
CURSOR_THEME_NAME="DreamJourney"
THEME_PATH="$CONFIG_DIR/kali-dreamjourney-theme"

echo "[*] Iniciando el despliegue de la arquitectura visual Dream Journey..."

# 1. Gestión de Dependencias
echo "[*] Resolviendo dependencias de sistema..."
sudo apt update && sudo apt install -y kitty fastfetch chafa curl picom

# 2. Preparación de Estructura (Jerarquía Estricta X11)
mkdir -p "$CONFIG_DIR/fastfetch"
mkdir -p "$CONFIG_DIR/kitty"
mkdir -p "$ICONS_DIR/$CURSOR_THEME_NAME/cursors"
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$THEME_PATH/assets"
mkdir -p "$CONFIG_DIR/gtk-3.0"

# 3. Ensamblaje del Tema de Cursores
echo "[*] Configurando los binarios del cursor..."
cp -r "$REPO_DIR/cursors/"* "$ICONS_DIR/$CURSOR_THEME_NAME/cursors/"

cat <<EOF > "$ICONS_DIR/$CURSOR_THEME_NAME/index.theme"
[Icon Theme]
Name=$CURSOR_THEME_NAME
Comment=Tema de cursores inspirado en Dream Journey
Inherits=core
EOF

chmod -R 755 "$ICONS_DIR/$CURSOR_THEME_NAME"

# 4. Migración de Recursos Estáticos
echo "[*] Transfiriendo configuraciones y recursos multimedia..."
cp "$REPO_DIR/config/fastfetch/config.jsonc" "$CONFIG_DIR/fastfetch/" 2>/dev/null || true
cp "$REPO_DIR/config/kitty/kitty.conf" "$CONFIG_DIR/kitty/" 2>/dev/null || true
cp "$REPO_DIR/assets/Logo.png" "$THEME_PATH/assets/" 2>/dev/null || true
cp "$REPO_DIR/wallpapers/Story_Still_still_090043083_00_(difference02).png" "$WALLPAPER_DIR/dream_journey.png" 2>/dev/null || true

# 5. Personalización del Panel XFCE (Inyección GTK3 CSS)
echo "[*] Inyectando hojas de estilo para el panel superior..."
cat <<EOF > "$CONFIG_DIR/gtk-3.0/gtk.css"
/* Estructura de estilos Dream Journey para xfce4-panel */
.xfce4-panel {
    background-color: rgba(13, 13, 13, 0.85); 
    color: #f2e0d0;
    border-bottom: 2px solid #735d63;
}
.xfce4-panel button {
    background: transparent;
    border: none;
    color: #f2e0d0;
}
.xfce4-panel button:hover {
    background-color: rgba(115, 93, 99, 0.5);
    color: #f2d22e;
}
#clock-button {
    color: #f2d22e;
    font-weight: bold;
}
EOF

# 6. Manipulación del Entorno XFCE (Demons)
echo "[*] Aplicando parámetros en el registro XFCE..."
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "$CURSOR_THEME_NAME"

for property in $(xfconf-query -c xfce4-desktop -p /backdrop -l | grep "last-image"); do
    xfconf-query -c xfce4-desktop -p "$property" -s "$WALLPAPER_DIR/dream_journey.png"
done

# 7. Modificación del Gestor de Arranque (LightDM)
echo "[*] Sobrescribiendo la configuración del inicio de sesión (Root requerido)..."
sudo mkdir -p /usr/share/backgrounds
sudo cp "$WALLPAPER_DIR/dream_journey.png" /usr/share/backgrounds/dream_journey.png

sudo tee /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null <<EOF
[greeter]
background = /usr/share/backgrounds/dream_journey.png
theme-name = Adwaita-dark
icon-theme-name = $CURSOR_THEME_NAME
cursor-theme-name = $CURSOR_THEME_NAME
font-name = Monospace 11
indicators = ~host;~spacer;~clock;~spacer;~session;~power
EOF

# 8. Asignación de Intérpretes (Terminal y Shell)
echo "[*] Estableciendo políticas de terminal y análisis de sistema..."
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50
sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty

if ! grep -q "fastfetch" "$HOME/.zshrc"; then
    echo -e "\n# Lanzamiento automático de Fastfetch\nfastfetch" >> "$HOME/.zshrc"
fi

# 9. Sincronización de Componentes Activos
echo "[*] Reiniciando componentes visuales en caliente..."
(xfce4-panel -r &)
# ==============================================================================
# MÓDULO PICOM: Motor de Composición Gráfica
# ==============================================================================
echo "[*] Desplegando el motor de composición por hardware (Picom)..."

# 1. Desactivar el compositor heredado de XFCE mediante xfconf
xfconf-query -c xfwm4 -p /general/use_compositing -s false

# 2. Generar directorio y manifiesto de renderizado
mkdir -p "$CONFIG_DIR/picom"
cat <<EOF > "$CONFIG_DIR/picom/picom.conf"
# Backend GLX para procesamiento por GPU
backend = "glx";
glx-no-stencil = true;
glx-copy-from-front = false;
vsync = true;

# Geometría de Sombras (Mapeo a paleta Dream Journey #0D0D0D)
shadow = true;
shadow-radius = 12;
shadow-offset-x = -10;
shadow-offset-y = -10;
shadow-opacity = 0.7;
shadow-color = "#0D0D0D";
shadow-exclude = [
  "name = 'Notification'",
  "class_g = 'Conky'",
  "window_type = 'dock'",
  "_GTK_FRAME_EXTENTS@:c"
];

# Desenfoque de profundidad (Dual Kawase) para terminales transparentes
blur-background = true;
blur-method = "dual_kawase";
blur-strength = 5;
blur-background-exclude = [
  "window_type = 'desktop'",
  "_GTK_FRAME_EXTENTS@:c"
];

# Interpolación de esquinas
corner-radius = 8;
rounded-corners-exclude = [
  "window_type = 'dock'",
  "window_type = 'desktop'"
];

# Transiciones de estado (Fading)
fading = true;
fade-in-step = 0.04;
fade-out-step = 0.04;
fade-delta = 4;
EOF

# 3. Automatización de arranque dePicom
mkdir -p "$CONFIG_DIR/autostart"
cat <<EOF > "$CONFIG_DIR/autostart/picom.desktop"
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Name=Picom Compositor
Comment=Motor de renderizado GLX para X11
Exec=picom -b
OnlyShowIn=XFCE;
StartupNotify=false
Terminal=false
Hidden=false
EOF
# ==============================================================================
# MÓDULO ZSH: Personalización del Prompt Interactiva
# ==============================================================================
echo "[*] Inyectando la estética del intérprete de comandos en Zsh..."

# Verificación de idempotencia para no duplicar el código si se ejecuta 2 veces
if ! grep -q "Tema Dream Journey para Zsh" "$HOME/.zshrc"; then
    cat << 'EOF' >> "$HOME/.zshrc"

# ==========================================
# Tema Dream Journey para Zsh
# ==========================================
# Habilitar soporte de colores extendido
autoload -U colors && colors

# Variables de color basadas en la paleta hexadecimal
C_GOLD="%F{#f2d22e}"
C_CREAM="%F{#f2e0d0}"
C_ROSE="%F{#735d63}"
C_BROWN="%F{#655555}"
C_RESET="%f"

# Estructuración de un prompt de dos líneas
PROMPT="${C_GOLD}╭─${C_CREAM}[${C_ROSE}%n@%m${C_CREAM}] ${C_GOLD}󰁔 ${C_BROWN}%~ ${C_RESET}
${C_GOLD}╰─λ ${C_RESET}"

# Indicador de estado a la derecha (Muestra un check dorado si el comando fue exitoso, o una X rojiza si falló)
RPROMPT="%(?.${C_GOLD}✔.${C_ROSE}✘)%f"
# ==========================================
EOF
fi

echo "[+] Arquitectura instalada exitosamente."
echo "[!] Nota: Es necesario reiniciar el sistema completo para visualizar los cambios en LightDM."
