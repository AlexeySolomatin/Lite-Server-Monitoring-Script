#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Installation Step 01 - Environment Check
# -----------------------------------------------------------------------------

step_environment() {

    print_section "Environment Check"

    #
    # Root
    #

    if ! is_root; then
        log_error "This installer must be run as root."
        return 1
    fi

    log_success "Running as root."

    #
    # Supported OS
    #

    if ! is_supported_os; then
        log_error "Unsupported operating system."
        return 1
    fi

    log_success "Supported operating system detected."

    #
    # Bash
    #

    if (( BASH_VERSINFO[0] < 5 )); then
        log_error "Bash 5.0 or newer is required."
        return 1
    fi

    log_success "Bash version: ${BASH_VERSION}"

    #
    # APT
    #

    if ! command_exists apt-get; then
        log_error "apt-get not found."
        return 1
    fi

    log_success "APT package manager found."

    #
    # Architecture
    #

    case "$(uname -m)" in
        x86_64|aarch64)
            log_success "Supported architecture: $(uname -m)"
            ;;
        *)
            log_error "Unsupported architecture: $(uname -m)"
            return 1
            ;;
    esac

    #
    # Internet
    #

    if has_internet; then
        log_success "Internet connection available."
    else
        log_warn "Internet connection unavailable."
    fi

    #
    # Memory
    #

    local memory_mb
    memory_mb=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)

    if (( memory_mb < 512 )); then
        log_error "At least 512 MB RAM is required."
        return 1
    fi

    log_success "Memory: ${memory_mb} MB"

    #
    # Disk
    #

    local free_mb
    free_mb=$(df -Pm / | awk 'NR==2 {print $4}')

    if (( free_mb < 1024 )); then
        log_error "At least 1 GB of free disk space is required."
        return 1
    fi

    log_success "Free disk space: ${free_mb} MB"

    #
    # Writable directories
    #

    for dir in /opt /etc /var; do

        if [[ ! -w "${dir}" ]]; then
            log_error "Directory is not writable: ${dir}"
            return 1
        fi

    done

    log_success "Filesystem permissions OK."

    return 0

}
