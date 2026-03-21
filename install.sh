#!/bin/bash

# Fastfetch KDE Splash Screen Installer
# MIT License - herzane

set -e

# Language detection (TR or EN)
if [[ $LANG == "tr"* ]]; then
    MSG_DONE="✅ Kurulum tamamlandı!"
    MSG_USE="📌 Kullanım:"
    MSG_STEP1="1. Sistem Ayarları > Görünüm > Açılış Ekranı (Splash Screen)"
    MSG_STEP2="2. 'fastfetch' temasını seçin ve Uygula'ya tıklayın."
    MSG_NOTE="💡 Not: 'fastfetch' paketinin kurulu olduğundan emin olun."
    MSG_REMOVING="🗑️ Eski kopya siliniyor..."
else
    MSG_DONE="✅ Installation complete!"
    MSG_USE="📌 Usage:"
    MSG_STEP1="1. System Settings > Appearance > Splash Screen"
    MSG_STEP2="2. Select 'fastfetch' and click Apply."
    MSG_NOTE="💡 Note: Make sure the 'fastfetch' package is installed."
    MSG_REMOVING="🗑️ Removing old version..."
fi


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

echo "$MSG_DONE"
echo ""
echo "$MSG_USE"
echo "   $MSG_STEP1"
echo "   $MSG_STEP2"
echo ""
echo "$MSG_NOTE"
