#!/bin/bash

# Fastfetch KDE Splash Screen Installer
# MIT License - herzane

set -e

echo "🚀 Fastfetch KDE Splash Screen Kurulumu Başlıyor..."

# Hedef dizini oluştur
TARGET_DIR="$HOME/.local/share/plasma/look-and-feel/fastfetch-splash"

# Eğer eski kurulum varsa yedekle
if [ -d "$TARGET_DIR" ]; then
    echo "⚠️  Mevcut kurulum bulundu, yedekleniyor..."
    mv "$TARGET_DIR" "$TARGET_DIR.backup.$(date +%s)"
fi

# Dizini oluştur
mkdir -p "$TARGET_DIR"

# Dosyaları kopyala
echo "📦 Dosyalar kopyalanıyor..."
cp -r contents "$TARGET_DIR/"
cp metadata.json "$TARGET_DIR/"

echo "✅ Kurulum tamamlandı!"
echo ""
echo "📌 Kullanım:"
echo "   1. Sistem Ayarları > Görünüm > Açılış Ekranı"
echo "   2. 'fastfetch' temasını seçin"
echo "   3. Uygula butonuna tıklayın"
echo ""
echo "💡 Not: fastfetch paketinin kurulu olduğundan emin olun:"
echo "   sudo apt install fastfetch  # Debian/Ubuntu"
echo "   sudo pacman -S fastfetch    # Arch Linux"
echo ""
