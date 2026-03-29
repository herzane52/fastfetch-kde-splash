# Fastfetch KDE Splash

<p align="center">
  <img src="contents/previews/splash.png" alt="Fastfetch Splash Görünümü" width="100%">
</p>

<p align="center">
  <video src="video.mp4" width="100%" controls autoplay loop muted></video>
</p>
This project is a "hacker/matrix style" splash animation for KDE Plasma that displays real-time system information using the `fastfetch` tool.

[English](README.md) | [Türkçe](README.tr.md)

## Requirements

*   **KDE Plasma:** Version 5 or 6.
*   **Fastfetch:** Must be installed and accessible via the terminal.
*   **Qt5Compat.GraphicalEffects:** Required for visual effects to work.

## Features & Technical Details

* **Interactive Setup:** The installer runs interactively, asking you for your preferred theme color, layout (logo-only or full), and background transparency.
* **Premium Neon Glow:** All texts feature a multi-layered DropShadow effect, resembling a glowing neon sign.
* **Glitch/Matrix Effect:** Texts do not just appear; they form character by character in random positions, providing a futuristic aesthetic.
* **Backend:** The theme is QML-based and utilizes the `Plasma5Support` library to execute `fastfetch` commands in the background. It sanitizes ANSI color codes and parses the output reliably.

## Installation

Simply clone the repository and run the installation script:

```bash
git clone https://github.com/herzane52/fastfetch-kde-splash.git
cd fastfetch-kde-splash
```

```bash
chmod +x install.sh
./install.sh
```

*Note: The script will now ask you a few questions interactively. Just press **ENTER** to apply the default settings (Red color, Logo-only layout, Black background).*

## Usage

1. Open **System Settings**.
2. Navigate to **Appearance > Splash Screen**.
3. Select **fastfetch-splash** from the list and click **Apply**.

## License

Protected under the MIT License.
