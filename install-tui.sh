#!/bin/bash

# Fastfetch KDE Splash Screen - Independent TUI Installer (whiptail)
# Shell-only. No dependency on install.sh.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v whiptail >/dev/null 2>&1; then
    echo "whiptail not found. Falling back to CLI installer..."
    exec "$SCRIPT_DIR/install.sh" --cli "$@"
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

if [ ${#LANG_CODES[@]} -gt 0 ]; then
    lang_args=()
    for i in "${!LANG_CODES[@]}"; do
        lang_args+=("${LANG_CODES[$i]}" "${LANG_NAMES[$i]}")
    done

    lang_choice=$(whiptail --title "Language Selection" --menu "Select your language:" 20 76 12 \
        --default-item "en" \
        "${lang_args[@]}" 3>&1 1>&2 2>&3) || exit 0
    LANG_FILE="$SCRIPT_DIR/lang/$lang_choice.sh"
else
    LANG_FILE="$SCRIPT_DIR/lang/en.sh"
fi

source "${LANG_FILE:-$SCRIPT_DIR/lang/en.sh}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

hex_to_ansi() {
    local hex="${1#\#}"
    [ ${#hex} -eq 3 ] && hex="${hex:0:1}${hex:0:1}${hex:1:1}${hex:1:1}${hex:2:1}${hex:2:1}"
    local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
    printf '\033[38;2;%d;%d;%dm' "$r" "$g" "$b"
}

colorize_text() {
    local hex="$1"
    if [[ "$hex" != \#* ]]; then
        cat
        return
    fi
    local ansi reset
    ansi=$(hex_to_ansi "$hex")
    reset=$'\033[0m'
    sed "s/[^ ]/${ansi}&${reset}/g"
}

get_logo_list() {
    fastfetch --list-logos 2>/dev/null | grep -o '"[^"]*"' | tr -d '"' | awk '!seen[$0]++'
}

preview_logo() {
    local logo="$1"
    local type="${2:-}"
    local out
    if [ "$type" = "file" ]; then
        out=$(fastfetch --logo "$logo" --logo-type file --structure L 2>/dev/null || true)
    else
        out=$(fastfetch --logo "$logo" --structure L 2>/dev/null || true)
    fi

    clear
    echo "================================================================================"
    echo "  ${MSG_TUI_PREVIEW:-Preview}: $logo"
    echo "================================================================================"
    echo ""
    printf '%s\n' "$out" | colorize_text "$COLOR"
    echo ""
    echo "================================================================================"
    echo ""
}

# Defaults
COLOR="#ffffff"
LAYOUT="logo"
BGCOLOR="#000000"
LOGO_MODE=""
LOGO_VALUE=""

# ---------------------------------------------------------------------------
# Settings steps (return 0 OK, 1 back/cancel)
# ---------------------------------------------------------------------------

choose_color() {
    local prompt="${MSG_TUI_CHOOSE_COLOR:-Select a theme color}"
    local cancel_lbl="${MSG_TUI_CANCEL:-Cancel}"
    local choice
    choice=$(whiptail --title "$MSG_TUI_COLOR" --menu "$prompt" 20 76 10 \
        1 "${COLOR_WHITE:-White (#ffffff)}" \
        2 "${COLOR_RED:-Red (#ff0000)}" \
        3 "${COLOR_BLUE:-Blue (#0080ff)}" \
        4 "${COLOR_GREEN:-Green (#00ff00)}" \
        5 "${COLOR_CYAN:-Cyan (#00ffff)}" \
        6 "${COLOR_YELLOW:-Yellow (#ffff00)}" \
        7 "${COLOR_PURPLE:-Purple (#8000ff)}" \
        8 "${COLOR_CUSTOM:-Custom HEX}" \
        I "$cancel_lbl" \
        3>&1 1>&2 2>&3) || return 1
    case "$choice" in
        1) COLOR="#ffffff" ;;
        2) COLOR="#ff0000" ;;
        3) COLOR="#0080ff" ;;
        4) COLOR="#00ff00" ;;
        5) COLOR="#00ffff" ;;
        6) COLOR="#ffff00" ;;
        7) COLOR="#8000ff" ;;
        8) COLOR=$(whiptail --title "$MSG_TUI_COLOR" --inputbox "HEX (e.g. #ffffff)" 10 76 "$COLOR" 3>&1 1>&2 2>&3) || return 1 ;;
        I|*) return 1 ;;
    esac
    return 0
}

choose_layout() {
    local prompt="${MSG_TUI_CHOOSE_LAYOUT:-Select layout mode}"
    local cancel_lbl="${MSG_TUI_CANCEL:-Cancel}"
    local res
    res=$(whiptail --title "$MSG_TUI_LAYOUT" --menu "$prompt" 16 76 4 \
        1 "${LAYOUT_LOGO:-Logo only}" \
        2 "${LAYOUT_FULL:-Logo + System info (full)}" \
        3 "${LAYOUT_INFO:-System info only (info)}" \
        4 "$cancel_lbl" \
        3>&1 1>&2 2>&3) || return 1
    case "$res" in
        1) LAYOUT="logo" ;;
        2) LAYOUT="full" ;;
        3) LAYOUT="info" ;;
        4|*) return 1 ;;
    esac
    return 0
}

choose_bg() {
    local prompt="${MSG_TUI_CHOOSE_BG:-Select background}"
    local cancel_lbl="${MSG_TUI_CANCEL:-Cancel}"
    local choice
    choice=$(whiptail --title "$MSG_TUI_BG" --menu "$prompt" 16 76 5 \
        1 "${BG_BLACK:-Black (#000000)}" \
        2 "${BG_TRANSPARENT:-Transparent}" \
        3 "${BG_CUSTOM:-Custom HEX}" \
        4 "$cancel_lbl" \
        3>&1 1>&2 2>&3) || return 1
    case "$choice" in
        1) BGCOLOR="#000000" ;;
        2) BGCOLOR="transparent" ;;
        3) BGCOLOR=$(whiptail --title "$MSG_TUI_BG" --inputbox "HEX (e.g. #1a1a1a)" 10 76 "$BGCOLOR" 3>&1 1>&2 2>&3) || return 1 ;;
        4|*) return 1 ;;
    esac
    return 0
}

browse_logos() {
    local query=""
    local -a ALL=() FILTERED=()

    mapfile -t ALL < <(get_logo_list)
    if [ "${#ALL[@]}" -eq 0 ]; then
        whiptail --title "$MSG_TUI_LOGO" --msgbox "${LOGO_NOT_FOUND:-Could not retrieve logo list. Is fastfetch installed?}" 10 76
        return 1
    fi

    while true; do
        if [ -z "$query" ]; then
            FILTERED=("${ALL[@]}")
        else
            mapfile -t FILTERED < <(printf '%s\n' "${ALL[@]}" | grep -i -- "$query")
        fi

        if [ "${#FILTERED[@]}" -eq 0 ]; then
            whiptail --title "$MSG_TUI_LOGO" --msgbox "${LOGO_NO_MATCH:-No matching logo found:} $query" 10 76
            query=""
            continue
        fi

        local args=()
        args+=("S" "${MSG_TUI_SEARCH:-Search (filter)}")
        local i
        for ((i = 0; i < ${#FILTERED[@]}; i++)); do
            args+=("$((i + 1))" "${FILTERED[$i]}")
        done
        args+=("I" "${MSG_TUI_CANCEL:-Cancel}")

        local choice
        choice=$(whiptail --title "$MSG_TUI_LOGO" --menu "${MSG_TUI_CHOOSE_LOGO:-Select a logo}" 30 76 20 "${args[@]}" 3>&1 1>&2 2>&3) || return 1

        case "$choice" in
            S)
                query=$(whiptail --title "$MSG_TUI_SEARCH" --inputbox "${MSG_TUI_SEARCH:-Search query (empty = all):}" 10 76 "$query" 3>&1 1>&2 2>&3) || query="$query"
                ;;
            I) return 1 ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#FILTERED[@]}" ]; then
                    local selected="${FILTERED[$((choice - 1))]}"
                    preview_logo "$selected"
                    read -p "${LOGO_PROMPT_USE:-Use selected logo?} ($selected) [Y/n]: " confirm
                    clear
                    if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
                        LOGO_MODE="logo"
                        LOGO_VALUE="$selected"
                        return 0
                    fi
                fi
                ;;
        esac
    done
}

choose_logo() {
    while true; do
        local choice
        choice=$(whiptail --title "$MSG_TUI_LOGO" --menu "${MSG_TUI_CHOOSE_LOGO:-Select a logo}" 16 76 5 \
            1 "${LOGO_OPTION_ALL:-Logo list (all)}" \
            2 "${LOGO_OPTION_DEFAULT:-Default (OS logo)}" \
            3 "${LOGO_OPTION_ASCII:-Project ASCII (ascii-logo.txt)}" \
            4 "${MSG_TUI_CANCEL:-Cancel}" \
            3>&1 1>&2 2>&3) || return 1
        case "$choice" in
            1)
                browse_logos && return 0
                ;;
            2)
                LOGO_MODE=""
                LOGO_VALUE=""
                return 0
                ;;
            3)
                if [ -f "$SCRIPT_DIR/ascii-logo.txt" ]; then
                    preview_logo "$SCRIPT_DIR/ascii-logo.txt" "file"
                    read -p "${LOGO_PROMPT_USE:-Use project ASCII logo?} [Y/n]: " confirm
                    clear
                    if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
                        LOGO_MODE="file"
                        LOGO_VALUE="$SCRIPT_DIR/ascii-logo.txt"
                        return 0
                    fi
                else
                    whiptail --title "$MSG_TUI_LOGO" --msgbox "${LOGO_ASCII_NOT_FOUND:-ascii-logo.txt not found.}" 10 76
                fi
                ;;
            4|*) return 1 ;;
        esac
    done
}

do_install() {
    local TARGET_DIR="$HOME/.local/share/plasma/look-and-feel/fastfetch-splash"
    local TARGET_QML

    if [ -d "$TARGET_DIR" ]; then
        rm -rf "$TARGET_DIR"
    fi
    mkdir -p "$TARGET_DIR"
    cp -r "$SCRIPT_DIR/contents" "$TARGET_DIR/"
    cp "$SCRIPT_DIR/metadata.json" "$TARGET_DIR/"

    TARGET_QML="$TARGET_DIR/contents/splash/Splash.qml"
    sed -i "s/property string themeColor: \".*\"/property string themeColor: \"$COLOR\"/g" "$TARGET_QML"
    sed -i "s/property string displayMode: \".*\"/property string displayMode: \"$LAYOUT\"/g" "$TARGET_QML"
    sed -i "s/property string bgColor: \".*\"/property string bgColor: \"$BGCOLOR\"/g" "$TARGET_QML"

    if [ "$LOGO_MODE" = "file" ] && [ -n "$LOGO_VALUE" ] && [ -f "$LOGO_VALUE" ]; then
        cp "$LOGO_VALUE" "$TARGET_DIR/contents/splash/custom-logo.txt"
        LOGO_VALUE="$TARGET_DIR/contents/splash/custom-logo.txt"
    fi

    if [ -n "$LOGO_VALUE" ]; then
        local LOGO_ARG=""
        if [ "$LOGO_MODE" = "file" ]; then
            LOGO_ARG="--logo \\\"$LOGO_VALUE\\\" --logo-type file"
        else
            LOGO_ARG="--logo \\\"$LOGO_VALUE\\\""
        fi
        local content needle replacement
        content=$(cat "$TARGET_QML")
        needle="fastfetch --structure L --pipe"
        replacement="fastfetch $LOGO_ARG --structure L --pipe"
        content="${content/$needle/$replacement}"
        printf '%s\n' "$content" > "$TARGET_QML"
    fi
}

# ---------------------------------------------------------------------------
# Main flow with back navigation
# ---------------------------------------------------------------------------

step=0
while true; do
    case "$step" in
        0)
            if choose_color; then step=1; else exit 0; fi
            ;;
        1)
            if choose_layout; then step=2; else exit 0; fi
            ;;
        2)
            if choose_bg; then step=3; else exit 0; fi
            ;;
        3)
            if [ "$LAYOUT" = "info" ]; then
                LOGO_MODE=""
                LOGO_VALUE=""
                step=4
            else
                if choose_logo; then step=4; else exit 0; fi
            fi
            ;;
        4)
            logo_display="${LOGO_VALUE:-${LABEL_DEFAULT:-Default}}"
            summary="${MSG_TUI_COLOR:-Color}: $COLOR\n${MSG_TUI_LAYOUT:-Layout}: $LAYOUT\n${MSG_TUI_BG:-Background}: $BGCOLOR\n${MSG_TUI_LOGO_LABEL:-Logo}: $logo_display"
            if whiptail --title "${MSG_TUI_CONFIRM:-Confirm}" --yesno "${MSG_TUI_APPLY_PROMPT:-Apply the following settings?}\n\n$summary" 16 76 3>&1 1>&2 2>&3; then
                do_install
                whiptail --title "${MSG_TUI_DONE:-Success}" --msgbox "${MSG_TUI_DONE:-Installation complete!}\n\n${MSG_STEP1:-1. System Settings > Appearance > Splash Screen}\n${MSG_STEP2:-2. Select 'fastfetch-splash' and click Apply.}" 12 76
                exit 0
            else
                step=3
            fi
            ;;
    esac
done
