#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# User Interface Library
# -----------------------------------------------------------------------------

[[ -n "${LSM_UI_LOADED:-}" ]] && return
readonly LSM_UI_LOADED=1

#
# Print application header
#
print_header() {

    echo
    printf "%b%s%b\n" "${COLOR_CYAN}${COLOR_BOLD}" \
        "Lite Server Monitor" \
        "${COLOR_RESET}"

    printf "%s\n" "Version ${PROJECT_VERSION}"
    echo

}

#
# Print section title
#
print_section() {

    echo
    printf "%b== %s ==%b\n" \
        "${COLOR_BLUE}" \
        "$1" \
        "${COLOR_RESET}"

}

#
# Wait for user
#
pause() {

    read -rp "Press Enter to continue..."

}

#
# Ask Yes / No
#
ask_yes_no() {

    local question="$1"
    local default="${2:-Y}"

    local prompt

    if [[ "${default^^}" == "Y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi

    while true; do

        read -rp "${question} ${prompt} " answer

        answer="${answer:-$default}"

        case "${answer,,}" in

            y|yes)
                return 0
                ;;

            n|no)
                return 1
                ;;

            *)
                log_warn "Please answer yes or no."
                ;;

        esac

    done

}

#
# Read text input
#
ask_input() {

    local prompt="$1"
    local default="${2:-}"

    if [[ -n "${default}" ]]; then
        read -rp "${prompt} [${default}]: " value
        echo "${value:-$default}"
    else
        read -rp "${prompt}: " value
        echo "${value}"
    fi

}

#
# Read password
#
ask_password() {

    local prompt="$1"

    read -rsp "${prompt}: " password

    echo

    echo "${password}"

}
