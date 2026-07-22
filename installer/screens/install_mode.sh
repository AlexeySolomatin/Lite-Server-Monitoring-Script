#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Installation Mode Screen
# -----------------------------------------------------------------------------

INSTALL_MODE="preset"

screen_install_mode() {

    wizard_header

    echo "Installation mode"
    echo
    echo "1) Quick installation (recommended)"
    echo "2) Custom installation"
    echo

    while true; do

        read -rp "Select mode [1-2]: " answer

        case "${answer}" in

            1)
                INSTALL_MODE="preset"
                break
                ;;

            2)
                INSTALL_MODE="custom"
                break
                ;;

        esac

    done

}
