# SMART Monitor Module

## Description

The SMART module monitors the health status of storage devices using `smartctl`
from the smartmontools package.

The module periodically checks all configured drives and reports:

- SMART overall health status
- Failed drives
- Prefail attributes
- Disk temperature (optional)
- Recovery notifications

Notifications are sent only when the device state changes to prevent alert spam.

---

## Features

- SMART health monitoring
- HDD and SSD support
- Configurable ignored devices
- Temperature reporting
- Alert / Recovery notifications
- Duplicate notification suppression
- systemd timer integration

---

## Requirements

Package:

```
smartmontools
```

Command:

```
smartctl
```

---

## Configuration

Configuration file:

```
/etc/lsm/modules/smart.conf
```

Example:

```ini
IGNORE_DEVICES=""
NOTIFY_ON_FAILURE=true
REPORT_TEMPERATURE=true
```

---

## Installed Files

```
/opt/lsm/modules/smart/check_smart.sh

/etc/systemd/system/lsm-smart.service

/etc/systemd/system/lsm-smart.timer

/etc/lsm/modules/smart.conf
```

---

## Default Schedule

```
Every 1 hour
```

---

## Notifications

The module generates notifications only when the SMART status changes.

Examples:

```
❌ SMART failure detected on /dev/sda
```

```
✅ SMART status restored on /dev/sda
```

---

## Dependencies

- smartmontools
- systemd
- LSM notification library
