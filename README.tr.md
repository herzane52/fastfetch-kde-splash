# Fastfetch KDE Splash v1.4

<p align="center">
  <img src="contents/previews/splash.png" alt="Fastfetch Splash Görünümü" width="100%">
</p>

<div align="center">
  <table>
    <tr>
      <td width="50%">
        <img src="video1.gif" width="100%">
      </td>
      <td width="50%">
        <img src="video2.gif" width="100%">
      </td>
    </tr>
  </table>
</div>

Bu proje, KDE Plasma masaüstü ortamı için `fastfetch` aracını kullanarak sistem bilgilerini açılış ekranında (Splash Screen) "hacker/matrix" tarzında görüntüleyen açılış animasyonudur.

[English](README.md) | [Türkçe](README.tr.md)

## 🌟 Özellikler

*   **Renk Seçimi:** İstediğiniz her tema rengini serbestçe seçebilirsiniz.
*   **Logo & Bilgi Düzenleri:** Sadece logo veya tüm detayların yer aldığı "full" mod arasından seçim yapabilirsiniz.
*   **Arka Plan Ayarları:** Arka plan rengini belirleyebilir veya şeffaf olarak ayarlayabilirsiniz.
*   **Şık Animasyon:** Sistemin açılışında karakterlerin tek tek belirdiği modern bir efektle karşılanın.

## 🛠️ Kurulum ve Yapılandırma

### 1. Kurulum Betiği ile (Önerilen)

`install.sh` betiği tüm işlemleri otomatikleştirir:
*   Tercihlerinizi (renk, düzen, arka plan) sorar.
*   Dosyaları doğru dizine (`~/.local/share/plasma/look-and-feel/fastfetch-splash`) kopyalar.
*   Yapılandırmayı otomatik olarak tamamlar.

```bash
#depoyu klonlamak için
git clone https://github.com/herzane52/fastfetch-kde-splash.git
cd fastfetch-kde-splash
```

```bash
#kurulum betiğini çalıştırma izni vermek için
chmod +x install.sh
```
```bash
#kurulum betiğini çalıştırmak için
./install.sh
```

### 2. Manuel (Elle) Yapılandırma (Mağaza Kullanıcıları)

Eğer temayı KDE Store üzerinden kurduysanız, "Configuration Required" hatasıyla karşılaşırsınız. Bunu düzeltmek için şu dosyayı (`~/.local/share/plasma/look-and-feel/fastfetch-splash/contents/splash/Splash.qml`) (10-13. satırlar arası) elle düzenleyebilirsiniz:

```bash
nano ~/.local/share/plasma/look-and-feel/fastfetch-splash/contents/splash/Splash.qml
```


*   `Splash.qml` dosyasını açın.
*   `property bool isConfigured` değerini `true` yapın.
*   `themeColor`, `displayMode` ve `bgColor` değerlerini isteğinize göre özelleştirin.

## 📋 Gereksinimler

*   **KDE Plasma:** 5 veya 6 sürümü.
*   **Fastfetch:** Sisteminizde kurulu olmalıdır.
*   **Qt5Compat.GraphicalEffects:** Görsel efektler için gereklidir.

## 🚀 Kullanım

1.  **Sistem Ayarları**'nı açın.
2.  **Görünüm > Açılış Ekranı** sekmesine gidin.
3.  Listeden **fastfetch-splash** öğesini seçin ve **Uygula**'ya tıklayın.

## 🛠️ Hata Çözümleri

*   **"Configuration Required" Hatası:** Temayı script (`install.sh`) kullanmadan kurduğunuzda bu uyarıyı alırsınız. Çözüm için `install.sh` betiğini çalıştırın veya `Splash.qml` dosyasındaki `isConfigured` değerini `true` yapın.
*   **"'fastfetch' not found" Hatası:** Sisteminizde `fastfetch` yüklü değildir. Dağıtımınızın paket yöneticisini kullanarak (`sudo pacman -S fastfetch` veya `sudo apt install fastfetch` gibi) yükleme yapın.
*   **"'fastfetch' returned empty output" Hatası:** Komut çalışıyor ancak çıktı veremiyor. Uçbirimde `fastfetch` komutunun normal çalıştığından emin olun.
*   **Görsel Hatalar/Eksiklikler:** Eğer efektler (neon parlama, glitch vb.) görünmüyorsa `Qt5Compat.GraphicalEffects` paketinin kurulu olduğundan emin olun.

## 📄 Lisans

MIT Lisansı ile korunmaktadır.
