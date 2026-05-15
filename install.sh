#!/bin/bash

# ==============================================================================
# Script de Despliegue: Kali Dream Journey Theme (V4 - Total Conversion VM-Safe)
# Autor: Haziel Ruiz Zuñiga
# Descripción: Arquitectura visual completa optimizada para máquinas virtuales.
#
#Oh whee
#
#      /\                  /
#      \ \ \              / /
#      (. \ \          / / . /
#      \.  # \_ --  _ \ / #  )
#      \_   /\      /\ -'
#      /  / # \ . . /  / # \
#     /   < .  >< /  \ . > -
#    /#      ,----. \   #\
#   /#/ |  /(o))\(o) \  |#
#  -//  \  \___  ___/ | \ \
#    |    \ \_  w  _/   \ )
#   / |    /   \ /    \  / \
#  /   \   \    \_/    /   \
# //   /    /----- \      \\
# \  /  \  \    /\  \/   \  |/
#  \|      / /-----  \ \ / |  |
#        /  /          \   //
#       /  /  XXXXX   \
#        /___|__|___ \

#
# ==============================================================================

set -e 

# Definición de variables de entorno
REPO_DIR=$(pwd)
CONFIG_DIR="$HOME/.config"
ICONS_DIR="$HOME/.icons"
WALLPAPER_DIR="$HOME/Imágenes/Wallpapers"
CURSOR_THEME_NAME="DreamJourney"
THEME_PATH="$CONFIG_DIR/kali-dreamjourney-theme"

echo "[*] Iniciando el despliegue del ecosistema visual Dream Journey..."

# 1. Gestión de Dependencias
sudo apt update && sudo apt install -y kitty fastfetch chafa curl picom

# 2. Preparación de Estructura Jerárquica
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
cp "$REPO_DIR/config/fastfetch/config.jsonc" "$CONFIG_DIR/fastfetch/" 2>/dev/null || true
cp "$REPO_DIR/config/kitty/kitty.conf" "$CONFIG_DIR/kitty/" 2>/dev/null || true
cp "$REPO_DIR/assets/Logo.png" "$THEME_PATH/assets/" 2>/dev/null || true
cp "$REPO_DIR/wallpapers/Story_Still_still_090043083_00_(difference02).png" "$WALLPAPER_DIR/dream_journey.png" 2>/dev/null || true

# 5. Panel XFCE (Inyección GTK3 CSS)
echo "[*] Inyectando hojas de estilo para el panel superior..."
cat <<EOF > "$CONFIG_DIR/gtk-3.0/gtk.css"
.xfce4-panel { background-color: rgba(13, 13, 13, 0.85); color: #f2e0d0; border-bottom: 2px solid #735d63; }
.xfce4-panel button { background: transparent; border: none; color: #f2e0d0; }
.xfce4-panel button:hover { background-color: rgba(115, 93, 99, 0.5); color: #f2d22e; }
#clock-button { color: #f2d22e; font-weight: bold; }
EOF


# 6. Registro XFCE
echo "[*] Aplicando parámetros en el gestor de ventanas y escritorio..."
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "$CURSOR_THEME_NAME"

for property in $(xfconf-query -c xfce4-desktop -p /backdrop -l | grep "last-image"); do
    xfconf-query -c xfce4-desktop -p "$property" -s "$WALLPAPER_DIR/dream_journey.png"
done

# Alineación de botones utilizando el tema nativo (Kali-Dark)
xfconf-query -c xfwm4 -p /general/title_alignment -s "center"
xfconf-query -c xfwm4 -p /general/button_layout -s "O|HMC"
# 7. Motor de Composición Seguro (Picom para VM)
echo "[*] Configurando aceleración de ventanas (Backend Xrender)..."
xfconf-query -c xfwm4 -p /general/use_compositing -s false
mkdir -p "$CONFIG_DIR/picom"
cat <<EOF > "$CONFIG_DIR/picom/picom.conf"
backend = "xrender";
vsync = false;
shadow = true;
shadow-radius = 12;
shadow-offset-x = -10;
shadow-offset-y = -10;
shadow-opacity = 0.7;
shadow-color = "#0D0D0D";
shadow-exclude = [ "name = 'Notification'", "class_g = 'Conky'", "window_type = 'dock'", "_GTK_FRAME_EXTENTS@:c" ];
corner-radius = 8;
rounded-corners-exclude = [ "window_type = 'dock'", "window_type = 'desktop'" ];
fading = true; fade-in-step = 0.04; fade-out-step = 0.04; fade-delta = 4;
EOF

mkdir -p "$CONFIG_DIR/autostart"
cat <<EOF > "$CONFIG_DIR/autostart/picom.desktop"
[Desktop Entry]
Type=Application
Name=Picom
Exec=picom -b
OnlyShowIn=XFCE;
StartupNotify=false
EOF

# ==============================================================================
# MÓDULO BINARIOS: Herramientas de Análisis Táctico
# ==============================================================================
echo "[*] Desplegando el motor de escaneo de red (Dream Scan)..."

# 1. Instanciación del directorio estándar para binarios de usuario
LOCAL_BIN_DIR="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN_DIR"

# 2. Transferencia del script y remoción de la extensión para invocación directa
cp "$REPO_DIR/bin/dream_scan.sh" "$LOCAL_BIN_DIR/dream_scan" 2>/dev/null || true

# 3. Asignación de bit de ejecución al analizador
chmod +x "$LOCAL_BIN_DIR/dream_scan"

# 4. Verificación de la variable de entorno PATH en el intérprete Zsh
# Es imperativo que ~/.local/bin esté en el PATH para invocar el comando globalmente
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc"; then
    echo -e "\n# Extensión del PATH para binarios locales\nexport PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
fi

# 8. Modificación de Zsh y Terminal
echo "[*] Estableciendo shell interactiva y emulador nativo..."
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50
sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty

if ! grep -q "Tema Dream Journey para Zsh" "$HOME/.zshrc"; then
    cat << 'EOF' >> "$HOME/.zshrc"
# Tema Dream Journey para Zsh
autoload -U colors && colors
C_GOLD="%F{#f2d22e}"; C_CREAM="%F{#f2e0d0}"; C_ROSE="%F{#735d63}"; C_BROWN="%F{#655555}"; C_RESET="%f"
PROMPT="${C_GOLD}╭─${C_CREAM}[${C_ROSE}%n@%m${C_CREAM}] ${C_GOLD}󰁔 ${C_BROWN}%~ ${C_RESET}
${C_GOLD}╰─λ ${C_RESET}"
RPROMPT="%(?.${C_GOLD}✔.${C_ROSE}✘)%f"
fastfetch
EOF
fi

# 9. LightDM y GRUB2 (Root)
echo "[*] Sobrescribiendo interfaces de arranque (LightDM y GRUB)..."
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

# 10. Sincronización
echo "[*] Reiniciando componentes visuales de la sesión activa..."
(xfce4-panel -r &)
(xfwm4 --replace &)
(killall picom 2>/dev/null; picom -b)

echo "[+] Entorno de despliegue finalizado. Se recomienda reiniciar el equipo (reboot)."
