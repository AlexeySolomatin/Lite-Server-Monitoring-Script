#!/usr/bin/env bash

step_modules() {

    log_step "Installing modules"

    for module in "${SELECTED_MODULES[@]}"; do
        modules_install "${module}"
    done

}
