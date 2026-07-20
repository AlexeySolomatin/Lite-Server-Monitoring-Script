# UPS Monitor Module

## Description

The UPS module monitors UPS status through apcupsd.

## Features

- Online/offline detection
- Battery monitoring
- Runtime monitoring
- Low battery alerts
- Recovery notifications


## Requirements

- apcupsd


## Configuration

```
/etc/lsm/modules/ups.conf
```


## Installed Files

```
/opt/lsm/modules/ups/check_ups.sh

/etc/systemd/system/lsm-ups.service

/etc/systemd/system/lsm-ups.timer

/etc/lsm/modules/ups.conf
```

## Default Schedule

Every minute.
