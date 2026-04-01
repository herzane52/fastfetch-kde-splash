#!/bin/bash

# Fastfetch KDE Splash Screen Installer
# MIT License - herzane

set -e

# Language detection (Default: EN, switch to TR if $LANG starts with 'tr')
LANG_SYS="en"
if [[ $LANG == "tr"* ]]; then
    LANG_SYS="tr"
fi

# Define messages based on language
if [[ "$LANG_SYS" == "tr" ]]; then
    MSG_WELCOME="=== Fastfetch KDE Açılış Ekranı Kurulumu ==="
    MSG_HINT="💡 Not: Varsayılan ayarı seçmek için hiçbir şey yazmadan doğrudan [ENTER] tuşuna basabilirsiniz."
    
    MSG_C_TEXT="1. Tema rengini seçin:\n  [1] Kırmızı (red)\n  [2] Mavi (blue)\n  [3] Yeşil (green)\n  [4] Camgöbeği (cyan)\n  Veya özel HEX kodu girin (Örn: #637C76)"
    MSG_C_INPUT="Seçiminiz [Varsayılan: 1]: "

    MSG_L_TEXT="2. Hangi düzeni kullanmak istersiniz?\n  [1] Sadece logo\n  [2] Logo + Sistem bilgisi (full)"
    MSG_L_INPUT="Seçiminiz [Varsayılan: 1]: "

    MSG_B_TEXT="3. Arka planı seçin:\n  [1] Siyah (black)\n  [2] Şeffaf (transparent)\n  Veya özel HEX kodu girin (Örn: #1a1a1a)"
    MSG_B_INPUT="Seçiminiz [Varsayılan: 1]: "

    MSG_INSTALLING="Kuruluyor..."
    MSG_DONE="✅ Kurulum tamamlandı! Seçimler -> Renk: %s, Düzen: %s, Arka Plan: %s"
    MSG_USE="📌 Kullanım:"
    MSG_STEP1="1. Sistem Ayarları > Görünüm > Açılış Ekranı (Splash Screen)"
    MSG_STEP2="2. 'fastfetch' temasını seçin ve Uygula'ya tıklayın."
    MSG_NOTE="💡 Not: 'fastfetch' paketinin kurulu olduğundan emin olun."
    MSG_REMOVING="🗑️ Eski kopya siliniyor..."
else
    MSG_WELCOME="=== Fastfetch KDE Splash Screen Installer ==="
    MSG_HINT="💡 Note: You can simply press [ENTER] to use the default selection."
    
    MSG_C_TEXT="1. Choose a theme color:\n  [1] Red\n  [2] Blue\n  [3] Green\n  [4] Cyan\n  Or enter a custom HEX code (e.g., #637C76)"
    MSG_C_INPUT="Your selection [Default: 1]: "

    MSG_L_TEXT="2. Which layout do you prefer?\n  [1] Logo only\n  [2] Logo + System info (full)"
    MSG_L_INPUT="Your selection [Default: 1]: "

    MSG_B_TEXT="3. Choose a background:\n  [1] Black\n  [2] Transparent\n  Or enter a custom HEX code (e.g., #1a1a1a)"
    MSG_B_INPUT="Your selection [Default: 1]: "

    MSG_INSTALLING="Installing..."
    MSG_DONE="✅ Installation complete! Selections -> Color: %s, Layout: %s, Background: %s"
    MSG_USE="📌 Usage:"
    MSG_STEP1="1. System Settings > Appearance > Splash Screen"
    MSG_STEP2="2. Select 'fastfetch' and click Apply."
    MSG_NOTE="💡 Note: Make sure the 'fastfetch' package is installed."
    MSG_REMOVING="🗑️ Removing old version..."
fi

echo "$MSG_WELCOME"
echo "$MSG_HINT"
echo ""

# Question 1: Color
echo -e "$MSG_C_TEXT"
read -p "$MSG_C_INPUT" INPUT_COLOR
INPUT_COLOR=${INPUT_COLOR:-1} # Default to 1 if empty
case "$INPUT_COLOR" in
    1|red) COLOR="#ff0000" ;;
    2|blue) COLOR="#0080ff" ;;
    3|green) COLOR="#00ff00" ;;
    4|cyan) COLOR="#00ffff" ;;
    yellow) COLOR="#ffff00" ;;
    purple) COLOR="#8000ff" ;;
    *) COLOR="$INPUT_COLOR" ;; # Hex code or custom
esac

echo ""

# Question 2: Layout
echo -e "$MSG_L_TEXT"
read -p "$MSG_L_INPUT" INPUT_LAYOUT
INPUT_LAYOUT=${INPUT_LAYOUT:-1} # Default to 1 if empty
case "$INPUT_LAYOUT" in
    2|full) LAYOUT="full" ;;
    *) LAYOUT="logo" ;; # Any other input defaults to logo
esac

echo ""

# Question 3: Background
echo -e "$MSG_B_TEXT"
read -p "$MSG_B_INPUT" INPUT_BG
INPUT_BG=${INPUT_BG:-1} # Default to 1 if empty
case "$INPUT_BG" in
    2|transparent) BGCOLOR="transparent" ;;
    1|black) BGCOLOR="#000000" ;;
    *) BGCOLOR="$INPUT_BG" ;; # Hex code or custom
esac

echo ""
echo "$MSG_INSTALLING"

# Target directory
TARGET_DIR="$HOME/.local/share/plasma/look-and-feel/fastfetch-splash"

# Remove existing installation to avoid duplicates in KDE settings
if [ -d "$TARGET_DIR" ]; then
    echo "$MSG_REMOVING"
    rm -rf "$TARGET_DIR"
fi

# Create directory
mkdir -p "$TARGET_DIR"

# Copy files
cp -r contents "$TARGET_DIR/"
cp metadata.json "$TARGET_DIR/"

# Inject settings into QML
TARGET_QML="$TARGET_DIR/contents/splash/Splash.qml"
sed -i "s/property bool isConfigured: .*/property bool isConfigured: true/g" "$TARGET_QML"
sed -i "s/property string themeColor: \".*\"/property string themeColor: \"$COLOR\"/g" "$TARGET_QML"
sed -i "s/property string displayMode: \".*\"/property string displayMode: \"$LAYOUT\"/g" "$TARGET_QML"
sed -i "s/property string bgColor: \".*\"/property string bgColor: \"$BGCOLOR\"/g" "$TARGET_QML"

echo ""
printf "$MSG_DONE\n" "$COLOR" "$LAYOUT" "$BGCOLOR"
echo ""
echo "$MSG_USE"
echo "   $MSG_STEP1"
echo "   $MSG_STEP2"
echo ""
echo "$MSG_NOTE"
