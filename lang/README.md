# Adding a New Language

Adding a new language is completely automatic! The installers (`install.sh` and `install-tui.sh`) dynamically discover all `.sh` files in this directory without modifying any script code.

## Steps

1. Copy `lang/en.sh` to `lang/xx.sh` (replace `xx` with your ISO language code, e.g., `pt.sh`, `pl.sh`, `az.sh`).
2. Set the language name at the top of the file:
   ```bash
   LANG_NAME="YourLanguage"
   ```
3. Translate the variables in your file.

Done! Both CLI and TUI installers will automatically list and support your language.

## Available Variables

| Variable | Description |
|---|---|
| `LANG_NAME` | Native display name of the language (e.g. `"Türkçe"`, `"English"`) |
| `MSG_WELCOME` | Title message |
| `MSG_HINT` | Default selection hint |
| `MSG_INSTALLING` | Installation in progress message |
| `MSG_DONE` | Installation completed message |
| `MSG_USE` | Usage instructions header |
| `MSG_STEP1` | Step 1 instructions |
| `MSG_STEP2` | Step 2 instructions |
| `MSG_NOTE` | Fastfetch dependency note |
| `MSG_REMOVING` | Removing old version message |
| `MSG_TUI_*` | Common UI labels and prompts |
| `COLOR_*` | Theme color option labels |
| `LAYOUT_*` | Layout option labels |
| `BG_*` | Background option labels |
| `LOGO_*` | Logo selection option labels |

## Testing

Test your language file in CLI mode:

```bash
LANG=xx_XX ./install.sh --cli
```

Or test in TUI mode:

```bash
LANG=xx_XX ./install.sh
```

Replace `xx_XX` with your locale (e.g., `de_DE`, `fr_FR`, `ja_JP`, `ru_RU`, `tr_TR`).
