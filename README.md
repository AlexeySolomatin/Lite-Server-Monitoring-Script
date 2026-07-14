# Lite-Server-Monitoring-Script
Lightweight modular monitoring toolkit for Ubuntu and Debian servers with Telegram, Email, SMART, RAID, UPS and Docker monitoring.
# Lite Server Monitoring Script

> Lightweight, modular and production-ready monitoring toolkit for Ubuntu and Debian servers.

Lite Server Monitoring Script is an open-source collection of Bash scripts designed to monitor the health of Linux servers without requiring Docker, databases, web interfaces, or heavyweight monitoring platforms.

The project focuses on simplicity, reliability and ease of deployment while providing essential monitoring features such as SMART, RAID, disk usage, system resources, UPS status and daily health reports.

---

## Why this project?

Many monitoring solutions are either:

- too complex
- require multiple services
- need databases
- require Docker or Kubernetes
- consume significant system resources

Lite Server Monitoring Script was created for administrators who simply need reliable monitoring with minimal configuration.

The project is designed for:

- Home Servers
- NAS
- Print Servers
- CCTV / NVR Servers
- Virtual Machines
- Small Business Infrastructure
- Dedicated Linux Servers

---

## Features

### Storage Monitoring

- SMART health monitoring
- RAID status monitoring
- Disk usage monitoring
- Recovery notifications
- Alert suppression using state files

### System Monitoring

- CPU usage
- Memory usage
- System Load
- Temperature monitoring

### UPS Monitoring

- APC UPS support (apcupsd)
- Battery events
- Power loss notifications
- Safe shutdown notifications

### Notifications

- Telegram
- Email (SMTP)
- Daily Health Report

### Reliability

- Lock protection (flock)
- State files
- Recovery detection
- Duplicate alert protection
- Safe repeated execution

---

## Project Philosophy

The project follows several simple principles:

- Lightweight
- Modular
- No Docker required
- No database required
- No web interface required
- Easy installation
- Easy removal
- Easy maintenance

---

## Supported Operating Systems

Currently supported:

- Ubuntu Server 22.04 LTS
- Ubuntu Server 24.04 LTS
- Debian 12

Additional distributions may be supported in future releases.

---

## Planned Monitoring Modules

| Module | Status |
|---------|--------|
| Disk Space | ✅ |
| SMART | ✅ |
| RAID | ✅ |
| CPU / RAM | ✅ |
| Temperature | ✅ |
| Daily Health Report | ✅ |
| Telegram Notifications | ✅ |
| Email Notifications | ✅ |
| UPS Monitoring | 🚧 |
| Docker Monitoring | 🚧 |

---

## Installation

Installation will be performed using a single command.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/<username>/Lite-Server-Monitoring-Script/main/bootstrap.sh)
```

The installer will:

- check system requirements
- install dependencies
- copy monitoring scripts
- configure notifications
- configure selected modules
- verify installation

---

## Project Structure

```

Lite-Server-Monitoring-Script/

├── install.sh
├── uninstall.sh
├── update.sh
├── bootstrap.sh
│
├── scripts/
├── lib/
├── templates/
├── systemd/
├── apcupsd/
│
├── docs/
└── tests/

```

---

## Documentation

Project documentation is available inside the **docs** directory.

- Project Specification
- Design Principles

Russian documentation is also included.

---

## Development Status

Current version:

```

0.1.0-alpha

```

The project is under active development.

Interfaces and installation process may change before the first stable release.

---

## Contributing

Bug reports, ideas and pull requests are welcome.

Please open an Issue before submitting major changes.

---

## License

Released under the MIT License.

See LICENSE for details.
