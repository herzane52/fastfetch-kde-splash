

# Fastfetch KDE Splash
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
## Gereksinimler

*   **KDE Plasma:** 5 veya 6 sürümü.
*   **Fastfetch:** Sisteminizde kurulu ve uçbirimden erişilebilir olmalıdır.
*   **Qt5Compat.GraphicalEffects:** Görsel efektlerin çalışması için gereklidir.



## Kurulum

Projeyi klonlayıp kurulum betiğini çalıştırmanız yeterlidir:
Kurulum betiği size sorular sorarak istediğiniz tema rengini, düzeni (sadece logo veya tam sistem bilgisi) ve arka plan şeffaflığını seçmenizi sağlar.

```bash
git clone https://github.com/herzane52/fastfetch-kde-splash.git
cd fastfetch-kde-splash
```

```bash
chmod +x install.sh
./install.sh
```

*Not: Script artık etkileşimli çalışmaktadır ve kurulum sırasında size sorular soracaktır. Varsayılan ayarları (Kırmızı renk, Sadece logo görünümü, Siyah arka plan) uygulamak için soruları boş bırakıp **ENTER**'a basabilirsiniz.*

## Kullanım

1. **Sistem Ayarları**'nı açın.
2. **Görünüm > Açılış Ekranı** sekmesine gidin.
3. Listeden **fastfetch-splash** öğesini seçin ve **Uygula**'ya tıklayın.

## Lisans

MIT Lisansı ile korunmaktadır.
