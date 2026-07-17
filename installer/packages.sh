#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Package management library
# -----------------------------------------------------------------------------

[[ -n "${LSM_INSTALLER_PACKAGES_LOADED:-}" ]] && return
readonly LSM_INSTALLER_PACKAGES_LOADED=1

#
# Update package cache
#
update_package_cache() {

    log_info "Updating package cache..."

    apt-get update

}

#
# Check whether a package is installed
#
package_installed() {

    dpkg -s "$1" >/dev/null 2>&1

}

#
# Install one package
#
install_package() {

    local package="$1"

    if package_installed "${package}"; then
        log_info "Package already installed: ${package}"
        return 0
    fi

    log_info "Installing package: ${package}"

    apt-get install -y "${package}"

}

#
# Install multiple packages
#
install_packages() {

    local package

    for package in "$@"; do
        install_package "${package}"
    done

}
