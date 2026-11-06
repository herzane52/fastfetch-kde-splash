#!/bin/bash

# Fastfetch KDE Splash Screen Installer
# MIT License - herzane

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Launch TUI automatically if whiptail is available and --cli is not requested
if [[ "$1" != "--cli" && "$1" != "--no-tui" ]]; then
    if command -v whiptail >/dev/null 2>&1 && [ -t 0 ]; then
        if [ -f "$SCRIPT_DIR/install-tui.sh" ]; then
            exec "$SCRIPT_DIR/install-tui.sh" "$@"
        fi
    fi
fi

# Dynamically discover all languages from lang/ folder (English first)
LANG_CODES=()
LANG_NAMES=()

if [ -f "$SCRIPT_DIR/lang/en.sh" ]; then
    en_name=$(grep -E '^[[:space:]]*LANG_NAME=' "$SCRIPT_DIR/lang/en.sh" | head -n1 | cut -d'"' -f2 || true)
    [ -z "$en_name" ] && en_name="English"
    LANG_CODES+=("en")
    LANG_NAMES+=("$en_name")
fi

for f in "$SCRIPT_DIR/lang/"*.sh; do
    [ -f "$f" ] || continue
    code=$(basename "$f" .sh)
    [ "$code" = "en" ] && continue
    name=$(grep -E '^[[:space:]]*LANG_NAME=' "$f" | head -n1 | cut -d'"' -f2 || true)
    [ -z "$name" ] && name="$code"
    LANG_CODES+=("$code")
    LANG_NAMES+=("$name")
done

# Default language is always English (1)
auto_code="en"
default_idx=1

# Language selection
echo ""
echo "=== Fastfetch KDE Splash Installer ==="
echo ""
echo "Languages:"
for i in "${!LANG_CODES[@]}"; do
    idx=$((i + 1))
    if [ "$idx" -eq "$default_idx" ]; then
        echo "  [$idx] ${LANG_NAMES[$i]} *"
    else
        echo "  [$idx] ${LANG_NAMES[$i]}"
    fi
done

read -p "Select language [Default: 1]: " lang_choice
lang_choice=${lang_choice:-1}
if [[ "$lang_choice" =~ ^[0-9]+$ ]] && [ "$lang_choice" -ge 1 ] && [ "$lang_choice" -le "${#LANG_CODES[@]}" ]; then
    selected_lang="${LANG_CODES[$((lang_choice - 1))]}"
else
    selected_lang="en"
fi

source "$SCRIPT_DIR/lang/$selected_lang.sh"

echo ""
echo "----------------------------------------"
echo "  $MSG_WELCOME"
echo "----------------------------------------"
echo "$MSG_HINT"
echo ""

# 1. Color Selection
echo "1. ${MSG_TUI_COLOR:-Theme Color}:"
echo "  [1] ${COLOR_WHITE:-White (#ffffff)} *"
echo "  [2] ${COLOR_RED:-Red (#ff0000)}"
echo "  [3] ${COLOR_BLUE:-Blue (#0080ff)}"
echo "  [4] ${COLOR_GREEN:-Green (#00ff00)}"
echo "  [5] ${COLOR_CYAN:-Cyan (#00ffff)}"
echo "  [6] ${COLOR_YELLOW:-Yellow (#ffff00)}"
echo "  [7] ${COLOR_PURPLE:-Purple (#8000ff)}"
echo "  [8] ${COLOR_CUSTOM:-Custom HEX}"
read -p "Selection [Default: 1]: " INPUT_COLOR
INPUT_COLOR=${INPUT_COLOR:-1}
case "$INPUT_COLOR" in
    1|white) COLOR="#ffffff" ;;
    2|red) COLOR="#ff0000" ;;
    3|blue) COLOR="#0080ff" ;;
    4|green) COLOR="#00ff00" ;;
    5|cyan) COLOR="#00ffff" ;;
    6|yellow) COLOR="#ffff00" ;;
    7|purple) COLOR="#8000ff" ;;
    8)
        read -p "HEX (e.g. #ffffff): " CUSTOM_COLOR
        COLOR="${CUSTOM_COLOR:-#ffffff}"
        ;;
    *) COLOR="$INPUT_COLOR" ;;
esac

echo ""

# 2. Layout Selection
echo "2. ${MSG_TUI_LAYOUT:-Layout}:"
echo "  [1] ${LAYOUT_LOGO:-Logo only} *"
echo "  [2] ${LAYOUT_FULL:-Logo + System info (full)}"
echo "  [3] ${LAYOUT_INFO:-System info only (info)}"
read -p "Selection [Default: 1]: " INPUT_LAYOUT
INPUT_LAYOUT=${INPUT_LAYOUT:-1}
case "$INPUT_LAYOUT" in
    2|full) LAYOUT="full" ;;
    3|info) LAYOUT="info" ;;
    *) LAYOUT="logo" ;;
esac

echo ""

# 3. Background Selection
echo "3. ${MSG_TUI_BG:-Background}:"
echo "  [1] ${BG_BLACK:-Black (#000000)} *"
echo "  [2] ${BG_TRANSPARENT:-Transparent}"
echo "  [3] ${BG_CUSTOM:-Custom HEX}"
read -p "Selection [Default: 1]: " INPUT_BG
INPUT_BG=${INPUT_BG:-1}
case "$INPUT_BG" in
    2|transparent) BGCOLOR="transparent" ;;
    3)
        read -p "HEX (e.g. #1a1a1a): " CUSTOM_BG
        BGCOLOR="${CUSTOM_BG:-#000000}"
        ;;
    *) BGCOLOR="#000000" ;;
esac

LOGO_MODE=""
LOGO_VALUE=""

# Helper: Retrieve and select from fastfetch logos in CLI
select_logo_from_list() {
    local -a ALL_LOGOS=()
    mapfile -t ALL_LOGOS < <(fastfetch --list-logos 2>/dev/null | grep -o '"[^"]*"' | tr -d '"' | awk '!seen[$0]++')
    if [ ${#ALL_LOGOS[@]} -eq 0 ]; then
        echo "Could not retrieve logo list from fastfetch."
        return 1
    fi

    while true; do
        echo ""
        read -p "Filter (e.g. arch, debian, ubuntu - press ENTER for all, 0 to go back): " search_term
        if [ "$search_term" = "0" ]; then
            return 1
        fi

        local -a MATCHED=()
        if [ -z "$search_term" ]; then
            MATCHED=("${ALL_LOGOS[@]}")
        else
            mapfile -t MATCHED < <(printf '%s\n' "${ALL_LOGOS[@]}" | grep -i -- "$search_term")
        fi

        if [ ${#MATCHED[@]} -eq 0 ]; then
            echo "No logos matching '$search_term'."
            continue
        fi

        echo ""
        echo "Found ${#MATCHED[@]} logo(s):"
        local count=${#MATCHED[@]}

        for ((j=0; j<count; j++)); do
            printf "  [%3d] %s\n" "$((j+1))" "${MATCHED[$j]}"
        done
        echo "  [  0] ${MSG_TUI_BACK:-Back}"

        echo ""
        read -p "Select a logo number [1-$count, 0=Back]: " l_num
        if [ "$l_num" = "0" ]; then
            return 1
        elif [[ "$l_num" =~ ^[0-9]+$ ]] && [ "$l_num" -ge 1 ] && [ "$l_num" -le "$count" ]; then
            LOGO_MODE="logo"
            LOGO_VALUE="${MATCHED[$((l_num - 1))]}"
            echo "Selected logo: $LOGO_VALUE"

            read -p "Preview this logo? [y/N]: " p_choice
            if [[ "$p_choice" =~ ^[Yy]$ ]]; then
                echo ""
                fastfetch --logo "$LOGO_VALUE" --structure L 2>/dev/null || true
                echo ""
            fi
            return 0
        else
            echo "Invalid selection."
        fi
    done
}

# 4. Logo Selection (if layout is not info)
if [ "$LAYOUT" != "info" ]; then
    while true; do
        echo ""
        echo "4. ${MSG_TUI_LOGO:-Logo Selection}:"
        echo "  [1] ${LOGO_OPTION_DEFAULT:-Default (OS logo)} *"
        if [ -f "$SCRIPT_DIR/ascii-logo.txt" ]; then
            echo "  [2] ${LOGO_OPTION_ASCII:-Project ASCII (ascii-logo.txt)}"
            echo "  [3] ${LOGO_OPTION_ALL:-Choose from logo list}"
        else
            echo "  [2] ${LOGO_OPTION_ALL:-Choose from logo list}"
        fi
        echo "  [0] ${MSG_TUI_BACK:-Back} (Use Default)"
        read -p "Selection [Default: 1]: " INPUT_LOGO
        INPUT_LOGO=${INPUT_LOGO:-1}
        case "$INPUT_LOGO" in
            1|0)
                LOGO_MODE=""
                LOGO_VALUE=""
                break
                ;;
            2)
                if [ -f "$SCRIPT_DIR/ascii-logo.txt" ]; then
                    LOGO_MODE="file"
                    LOGO_VALUE="$SCRIPT_DIR/ascii-logo.txt"
                    read -p "Preview ASCII logo? [y/N]: " p_choice
                    if [[ "$p_choice" =~ ^[Yy]$ ]]; then
                        echo ""
                        fastfetch --logo "$LOGO_VALUE" --logo-type file --structure L 2>/dev/null || true
                        echo ""
                    fi
                    break
                else
                    if select_logo_from_list; then
                        break
                    fi
                fi
                ;;
            3)
                if select_logo_from_list; then
                    break
                fi
                ;;
            *)
                LOGO_MODE=""
                LOGO_VALUE=""
                break
                ;;
        esac
    done
fi

echo ""
echo "----------------------------------------"
echo "  ${MSG_TUI_CONFIRM:-Summary}"
echo "----------------------------------------"
echo "  ${MSG_TUI_COLOR:-Color}: $COLOR"
echo "  ${MSG_TUI_LAYOUT:-Layout}: $LAYOUT"
echo "  ${MSG_TUI_BG:-Background}: $BGCOLOR"
if [ "$LAYOUT" != "info" ]; then
    echo "  ${MSG_TUI_LOGO_LABEL:-Logo}: ${LOGO_VALUE:-${LABEL_DEFAULT:-Default}}"
fi
echo ""

read -p "${MSG_TUI_APPLY_PROMPT:-Apply settings?} [Y/n]: " CONFIRM_INSTALL
if [[ "$CONFIRM_INSTALL" =~ ^[Nn]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "$MSG_INSTALLING"

TARGET_DIR="$HOME/.local/share/plasma/look-and-feel/fastfetch-splash"

if [ -d "$TARGET_DIR" ]; then
    echo "$MSG_REMOVING"
    rm -rf "$TARGET_DIR"
fi

mkdir -p "$TARGET_DIR"

cp -r contents "$TARGET_DIR/"
cp metadata.json "$TARGET_DIR/"

TARGET_QML="$TARGET_DIR/contents/splash/Splash.qml"
sed -i "s/property string themeColor: \".*\"/property string themeColor: \"$COLOR\"/g" "$TARGET_QML"
sed -i "s/property string displayMode: \".*\"/property string displayMode: \"$LAYOUT\"/g" "$TARGET_QML"
sed -i "s/property string bgColor: \".*\"/property string bgColor: \"$BGCOLOR\"/g" "$TARGET_QML"

if [ "$LOGO_MODE" = "file" ] && [ -n "$LOGO_VALUE" ] && [ -f "$LOGO_VALUE" ]; then
    cp "$LOGO_VALUE" "$TARGET_DIR/contents/splash/custom-logo.txt"
    LOGO_VALUE="$TARGET_DIR/contents/splash/custom-logo.txt"
fi

if [ -n "$LOGO_VALUE" ]; then
    LOGO_ARG=""
    if [ "$LOGO_MODE" = "file" ]; then
        LOGO_ARG="--logo \\\"$LOGO_VALUE\\\" --logo-type file"
    else
        LOGO_ARG="--logo \\\"$LOGO_VALUE\\\""
    fi
    content=$(cat "$TARGET_QML")
    needle="fastfetch --structure L --pipe"
    replacement="fastfetch $LOGO_ARG --structure L --pipe"
    content="${content/$needle/$replacement}"
    printf '%s\n' "$content" > "$TARGET_QML"
fi

echo ""
printf "$MSG_DONE\n" "$COLOR" "$LAYOUT" "$BGCOLOR"
echo ""
echo "$MSG_USE"
echo "   $MSG_STEP1"
echo "   $MSG_STEP2"
echo ""
echo "$MSG_NOTE"
