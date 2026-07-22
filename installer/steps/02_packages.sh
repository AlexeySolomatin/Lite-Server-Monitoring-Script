step_packages() {
    log_info "Installing required packages..."

    log_info "Updating package index..."
    
    # Защита от временных сбоев зеркал APT (mirror sync)
    if ! apt-get update -y; then
        log_warn "APT update failed (mirror sync or cache issue). Cleaning lists and retrying..."
        rm -rf /var/lib/apt/lists/*
        apt-get update -y || log_warn "APT update finished with warnings, proceeding with installation..."
    fi

    local pkgs=(curl wget jq bc msmtp smartmontools mdadm lm-sensors fail2ban)

    for pkg in "${pkgs[@]}"; do
        if dpkg -l | grep -q "^ii  $pkg "; then
            log_info "Package already installed: $pkg"
        else
            log_info "Installing package: $pkg..."
            DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
        fi
    done

    log_success "All required packages are installed."
}
