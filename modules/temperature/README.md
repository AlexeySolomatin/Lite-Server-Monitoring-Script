# Temperature Monitor Module

## Description

The Temperature module monitors CPU and system temperatures using standard Linux hardware monitoring interfaces.

## Features

- CPU temperature monitoring
- Configurable warning and critical thresholds
- Alert and recovery notifications
- Duplicate alert suppression
- systemd timer integration

## Requirements

- lm-sensors

## Configuration

```
/etc/lsm/modules/temperature.conf
```

## Installed Files

```
/opt/lsm/modules/temperature/check_temperature.sh

/etc/systemd/system/lsm-temperature.service

/etc/systemd/system/lsm-temperature.timer

/etc/lsm/modules/temperature.conf
```

## Default Schedule

Every 5 minutes.
