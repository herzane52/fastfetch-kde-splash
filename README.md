[English](README.md) | [Türkçe](README.tr.md)

# Fastfetch KDE Splash

<p align="center">
  <video src="video.mp4" width="100%" controls autoplay loop muted></video>
</p>

This project is a theme for the KDE Plasma desktop environment that displays real-time system information on the splash screen using the `fastfetch` tool.

## Requirements

*   **KDE Plasma:** Version 5 or 6.
*   **Fastfetch:** Must be installed and accessible via the terminal.
*   **Qt5Compat.GraphicalEffects:** Required for some visual effects to work.

## Technical Details

The theme is QML-based and utilizes the `Plasma5Support` library to execute `fastfetch` commands in the background. It sanitizes ANSI color codes from the output and displays the data in a Monospace layout.

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

## Usage

1. Open **System Settings**.
2. Navigate to **Appearance > Splash Screen**.
3. Select **fastfetch-splash** from the list and click **Apply**.

## License

Protected under the MIT License.
