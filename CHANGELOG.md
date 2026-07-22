# Changelog

All notable changes to the **Lite Server Monitor (LSM)** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-07-22

### Added
- **Core CLI Executable**: `bin/lsm` entry point supporting commands: `status`, `report`, `install`, `update`, `uninstall`, and `help`.
- **Global Symlink Installation**: Automatic creation of `/usr/local/bin/lsm` during step 07.
- **Monitoring Modules**: Complete installers and systemd timer integration for:
  - `system` (CPU, RAM, Disk, Load Average monitoring)
  - `raid` (MDADM & Hardware RAID status checks)
  - `smart` (S.M.A.R.T. disk drive diagnostics)
  - `temperature` (CPU & motherboard hardware sensors)
  - `ups` (Uninterruptible Power Supply status)
- **Core Libraries**:
  - `lib/core/common.sh` for environment detection and root checking.
  - `lib/core/ui.sh` for ANSI formatted visual outputs and header banners (`ui_banner`).
  - `lib/installer/deploy.sh` for safe file copying, permissions management, and symlinking.

### Fixed
- Fixed function name mismatch in package manager step (`packages_update_cache` -> `update_package_cache`).
- Resolved undefined `templates_install` command in `04_configuration.sh` with automatic `.bak` backups for existing configs.
- Fixed `ui_banner` missing function error in `installer/install.sh` and `installer/uninstall.sh`.
- Added fallback logic for `PROJECT_ROOT` and `LSM_ROOT` paths when running scripts from non-standard working directories.
- Updated placeholder scripts in `commands/` to functional execution wrappers.

### Security
- Restricted permissions on default configuration files (`640` for `/etc/lsm/config.conf` and module settings).
- Enforced strict `root` access controls across all installation and maintenance workflows.
