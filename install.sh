#!/bin/bash

# ==============================================================================
# Script de Despliegue: Kali Dream Journey Theme (Arquitectura Nativa - GPU)
# Autor: Haziel Ruiz Zuñiga
# Descripción: Total Conversion Theme con aceleración GLX y herramientas de red.
# ==============================================================================

set -e 

# 1. Definición de Variables de Entorno y Rutas Absolutas
REPO_DIR=$(pwd)
CONFIG_DIR="$HOME/.config"
ICONS_DIR="$HOME/.icons"
WALLPAPER_DIR="$HOME/Imágenes/Wallpapers"
LOCAL_BIN_DIR="$HOME/.local/bin"
CURSOR_THEME_NAME="DreamJourney"
THEME_PATH="$CONFIG_DIR/kali-dreamjourney-theme"

echo "[*] Inicializando despliegue en hardware físico (Bare Metal)..."

# 2. Gestión de Dependencias del Sistema
sudo apt update && sudo apt install -y kitty fastfetch chafa curl picom nmap bat

# 3. Construcción de la Topología de Directorios
mkdir -p "$CONFIG_DIR/fastfetch"
mkdir -p "$CONFIG_DIR/kitty"
mkdir -p "$CONFIG_DIR/picom"
mkdir -p "$CONFIG_DIR/gtk-3.0"
mkdir -p "$CONFIG_DIR/autostart"
mkdir -p "$ICONS_DIR/$CURSOR_THEME_NAME/cursors"
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$THEME_PATH/assets"
mkdir -p "$LOCAL_BIN_DIR"

# 4. Ensamblaje de Cursores
echo "[*] Compilando binarios de interacción espacial..."
cp -r "$REPO_DIR/cursors/"* "$ICONS_DIR/$CURSOR_THEME_NAME/cursors/" 2>/dev/null || true
cat <<EOF > "$ICONS_DIR/$CURSOR_THEME_NAME/index.theme"
[Icon Theme]
Name=$CURSOR_THEME_NAME
Comment=Arquitectura vectorial Dream Journey
Inherits=core
EOF
chmod -R 755 "$ICONS_DIR/$CURSOR_THEME_NAME"

# 5. Migración de Recursos Estáticos y Configuraciones
echo "[*] Transfiriendo manifiestos y matrices visuales..."
cp "$REPO_DIR/config/fastfetch/config.jsonc" "$CONFIG_DIR/fastfetch/" 2>/dev/null || true
cp "$REPO_DIR/config/kitty/kitty.conf" "$CONFIG_DIR/kitty/" 2>/dev/null || true
cp "$REPO_DIR/assets/Logo.png" "$THEME_PATH/assets/" 2>/dev/null || true
cp "$REPO_DIR/assets/ascii_art.txt" "$THEME_PATH/assets/" 2>/dev/null || true
cp "$REPO_DIR/wallpapers/dream_journey.png" "$WALLPAPER_DIR/dream_journey.png" 2>/dev/null || true

# 6. Módulo XFCE y Gestor de Ventanas (XFWM4)
echo "[*] Reconfigurando el motor de composición de escritorio..."
# Inyección CSS para el panel superior
cat <<EOF > "$CONFIG_DIR/gtk-3.0/gtk.css"
.xfce4-panel { background-color: rgba(13, 13, 13, 0.85); color: #f2e0d0; border-bottom: 2px solid #735d63; }
.xfce4-panel button { background: transparent; border: none; color: #f2e0d0; }
.xfce4-panel button:hover { background-color: rgba(115, 93, 99, 0.5); color: #f2d22e; }
#clock-button { color: #f2d22e; font-weight: bold; }
EOF

xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "$CURSOR_THEME_NAME"
for property in $(xfconf-query -c xfce4-desktop -p /backdrop -l | grep "last-image"); do
    xfconf-query -c xfce4-desktop -p "$property" -s "$WALLPAPER_DIR/dream_journey.png"
done

# Estabilización de bordes: Uso del motor nativo con reestructuración geométrica
xfconf-query -c xfwm4 -p /general/theme -s "Kali-Dark"
xfconf-query -c xfwm4 -p /general/title_alignment -s "center"
xfconf-query -c xfwm4 -p /general/button_layout -s "O|HMC"

# 7. Motor de Aceleración por Hardware (Picom GLX)
echo "[*] Habilitando pipeline OpenGL y algoritmos Dual Kawase..."
xfconf-query -c xfwm4 -p /general/use_compositing -s false
cat <<EOF > "$CONFIG_DIR/picom/picom.conf"
backend = "glx";
glx-no-stencil = true;
glx-copy-from-front = false;
vsync = true;

shadow = true;
shadow-radius = 12;
shadow-offset-x = -10;
shadow-offset-y = -10;
shadow-opacity = 0.7;
shadow-color = "#0D0D0D";
shadow-exclude = [ "name = 'Notification'", "class_g = 'Conky'", "window_type = 'dock'", "_GTK_FRAME_EXTENTS@:c" ];

blur-background = true;
blur-method = "dual_kawase";
blur-strength = 6;
blur-background-exclude = [ "window_type = 'desktop'", "_GTK_FRAME_EXTENTS@:c" ];

corner-radius = 8;
rounded-corners-exclude = [ "window_type = 'dock'", "window_type = 'desktop'" ];
fading = true; fade-in-step = 0.04; fade-out-step = 0.04; fade-delta = 4;
EOF

cat <<EOF > "$CONFIG_DIR/autostart/picom.desktop"
[Desktop Entry]
Type=Application
Name=Picom Compositor
Exec=picom -b
OnlyShowIn=XFCE;
StartupNotify=false
EOF

# 8. Despliegue de Binarios Locales (Dream Scan)
echo "[*] Integrando herramientas de análisis topológico..."
cp "$REPO_DIR/bin/dream_scan.sh" "$LOCAL_BIN_DIR/dream_scan" 2>/dev/null || true
chmod +x "$LOCAL_BIN_DIR/dream_scan"

# 9. Configuración del Intérprete (Zsh) y Terminal Nativa
echo "[*] Estableciendo variables de entorno y alias operativos..."
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50
sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty

if ! grep -q "Tema Dream Journey" "$HOME/.zshrc"; then
    cat << 'EOF' >> "$HOME/.zshrc"

# Configuración Dream Journey
export PATH="$HOME/.local/bin:$PATH"
alias cat='batcat --theme="base16" --style="header,grid"'

autoload -U colors && colors
C_GOLD="%F{#f2d22e}"; C_CREAM="%F{#f2e0d0}"; C_ROSE="%F{#735d63}"; C_BROWN="%F{#655555}"; C_RESET="%f"
PROMPT="${C_GOLD}╭─${C_CREAM}[${C_ROSE}%n@%m${C_CREAM}] ${C_GOLD}󰁔 ${C_BROWN}%~ ${C_RESET}
${C_GOLD}╰─λ ${C_RESET}"
RPROMPT="%(?.${C_GOLD}✔.${C_ROSE}✘)%f"

fastfetch
EOF
fi

# 10. Gestores de Arranque (LightDM y GRUB2)
echo "[*] Sobrescribiendo interfaces de inicialización del núcleo..."
sudo mkdir -p /usr/share/backgrounds
sudo cp "$WALLPAPER_DIR/dream_journey.png" /usr/share/backgrounds/dream_journey.png

sudo tee /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null <<EOF
[greeter]
background = /usr/share/backgrounds/dream_journey.png
theme-name = Kali-Dark
icon-theme-name = $CURSOR_THEME_NAME
cursor-theme-name = $CURSOR_THEME_NAME
font-name = Monospace 11
indicators = ~host;~spacer;~clock;~spacer;~session;~power
EOF

GRUB_THEME_DIR="/boot/grub/themes/DreamJourney"
sudo mkdir -p "$GRUB_THEME_DIR"
sudo cp "$WALLPAPER_DIR/dream_journey.png" "$GRUB_THEME_DIR/background.png"
sudo tee "$GRUB_THEME_DIR/theme.txt" > /dev/null <<EOF
title-text: ""
desktop-image: "background.png"
desktop-color: "#0D0D0D"
terminal-left: "15%"
terminal-top: "20%"
terminal-width: "70%"
terminal-height: "60%"
+ boot_menu { left = 15%; top = 30%; width = 70%; height = 50%; item_color = "#f2e0d0"; selected_item_color = "#f2d22e"; item_spacing = 8 }
EOF

sudo sed -i 's|^GRUB_THEME=.*$|#GRUB_THEME_ANTERIOR_DESACTIVADO|g' /etc/default/grub
if ! grep -q "GRUB_THEME=\"$GRUB_THEME_DIR/theme.txt\"" /etc/default/grub; then
    echo "GRUB_THEME=\"$GRUB_THEME_DIR/theme.txt\"" | sudo tee -a /etc/default/grub > /dev/null
fi
sudo update-grub

# 11. Sincronización de Procesos
echo "[*] Consolidando operaciones en el servidor de visualización..."
(xfce4-panel -r &)
(xfwm4 --replace &)
(killall picom 2>/dev/null; picom -b)

echo "[+] Entorno nativo compilado exitosamente. Se requiere reiniciar el sistema."
