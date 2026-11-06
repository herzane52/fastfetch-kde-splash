Fastfetch KDE Splash Screen v1.5.1

A KDE Plasma splash screen that presents 'fastfetch' in matrix/hacker style.

FEATURES:
- Color Selection: You can pick any color you like (the theme color).
- Layout Options: Logo-only, or "full" mode covering all information.
- Background Settings: Different color options or transparency support.

MANUAL CONFIGURATION - FOR KDE STORE USERS:
The store package contains only the theme files; `install.sh` is not included. Therefore you cannot configure color, layout and logo through the installer; everything must be edited by hand:

   `~/.local/share/plasma/look-and-feel/fastfetch-splash/contents/splash/Splash.qml`

WHAT YOU CAN DO (by editing the file manually):
- Theme color (`themeColor`, default white #ffffff)
- Layout (`displayMode`): logo only / logo + system info / info only
- Background (`bgColor`): color or transparent (default black #000000)
- Animation speed (`glitchInterval`, `introDuration`, `exitDuration`, `frameDivisor`)

WHAT YOU CANNOT DO (requires the installer script):
- Distro logo selection (search + preview from the fastfetch logo list)
- Adding your own ASCII logo (`ascii-logo.txt`)
For these you need to download and run `install.sh` from the GitHub repository.

With default settings the theme works with no changes at all:
the operating system logo from fastfetch appears in white on a black background.

GitHub Repository: https://github.com/herzane52/fastfetch-kde-splash
