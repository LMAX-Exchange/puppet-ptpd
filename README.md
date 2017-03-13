# ptpd

[![Build Status](https://travis-ci.org/LMAX-Exchange/puppet-ptpd.svg?branch=master)](https://travis-ci.org/LMAX-Exchange/puppet-ptpd)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [Requirements](#what-ptpd-affects)
    * [Beginning with ptpd](#beginning-with-ptpd)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)

## Overview

Manages the Precision Time Protocol (PTP) version 2 software, PTPd.


## Module Description

This module will manage the configuration files for ptpd, namely /etc/ptpd.conf, along with the
associated service.

This module is designed for ptpd version 2.3.2 or later, specifically with Linux PHC support built in.

Don't try and use this module to manage older versions of PTPd, such as those
found in RHEL 6 - there are significant changes the recent releases which means it probably won't work.

## Setup

### Requirements

This Puppet class is expected to work with ptpd version 2.3.2 with Linux PHC support, or later.
At the time of writing this was not merged into mainline, nor where there packages for it.

So, you need to build your own from source, which can be found here:

https://github.com/wowczarek/ptpd/tree/wowczarek-2.3.2-hwtest

This module depends on [b4ldr-logrotate](https://github.com/b4ldr/puppet-logrotate) for log rotation, but this can be disabled.

### Beginning with ptpd

Resource-like syntax is probably the better option, as you will need to configure the module:

~~~ puppet
class { 'ptpd:' }
~~~

Or if all your parameters are in Hiera:

~~~ puppet
include ptpd
~~~

If you've built ptpd with a different package name:

~~~ puppet
class { 'ptpd:'
  package_name => 'my-ptpd',
}
~~~

### Running an NTP-backed PTP Master

Have PTPd run as a Master Clock, sending out a signal on interface 'em1'. This assumes NTP is running and disciplining the System Clock:

~~~ puppet
class { 'ptpd:'
  ptpengine_interface     => 'em1',
  clock_master_clock_name => 'syst',
  ptpengine_preset        => 'masteronly',
}
~~~

## Reference

### Classes

#### Public Classes

* `ptpd`: Class that installs and configures ptpd.

### Parameters

#### ptpd

##### `ptpengine_interface`

The interface to listen to PTP on. Must be specified.

##### `ptpengine_domain`

PTP domain number. Usually zero, allows you to run multiple PTP streams on the same network and only listen to one of them.

Defaults to `0`.

##### `ptpengine_preset`

Either `slaveonly`, `masterslave`, or `masteronly`. Useful for making PTPd only ever be a slave, for example.

Defaults to `slaveonly`.

##### `ptpengine_hardware_timestamping`

Defaults to `true`.

##### `ptpengine_delay_mechanism`

Either `E2E` or `P2P`. Whether to use End to End or Peer to Peer delay detection. P2P only works when every device in
the network between master and slave is "PTP aware".

Defaults to `E2E`.

##### `ptpengine_ip_mode`

IP transmission mode, must be one of `multicast`, `hybrid`, or `unicast`. Hybrid mode is the "Enterprise" profile where
Sync and Announce messages are multicast from the master, but delay requests and responses are unicast from the slaves.

Defaults to `hybrid`.

##### `ptpengine_panic_mode`

Enable or disable panic mode, which disables clock updates for `ptpengine_panic_mode_duration` seconds and then steps
the clock if the offset is above 1 second.

Defaults to `y`.

##### `ptpengine_panic_mode_duration`

How long to be in panic mode for.

Default to `30`.

##### `servo_adev_locked_threshold_low_hw`

Minimum Allan Deviation of a hardware clock's frequency to be considered stable / locked.

Defaults to `50.000000`.

##### `servo_adev_locked_threshold_high_hw`

Allan Deviation of a hardware clock's frequency to be considered no longer stable.

Defaults to `500.000000`.

##### `servo_kp`

The kP value (proportional component gain) of the clock servo PI controller for software clocks.

Defaults to `undef`.

##### `servo_ki`

The kI value (integral component gain) of the clock servo PI controller for software clocks.

Defaults to `undef`.

##### `clock_leap_second_handling`

Controls behaviour during a leap seceond event. Should be one of `accept`, `ignore`, `step`, or `smear`.

Defaults to `accept`.

##### `clock_max_offset_ppm`

Maximum frequency shift which can be applied to a software clock servo.

Defaults to `500`.

##### `clock_master_clock_name`

The name of the preferred clock source.

Defaults to `undef`.

##### `global_log_file`

Location of the daemon log file.

Defaults to `/var/log/ptpd.log`.

##### `log_statistics`

Whether to log statistics to disk or not (can take a lot of space when fast Sync intervals are used). The location
of the statistics file is controlled by the `global_statistics_file` parameter.

Defaults to `true`.

##### `global_statistics_file`

Location of the statistics file.

Defaults to `/var/log/ptpd.stats`.

##### `global_lock_file`

Location of the daemon lock / PID file.

Defaults to `/var/run/ptpd.lock`.

##### `global_status_file`

Location of the daemon status file.

Defaults to `/var/run/ptpd.status`.

##### `package_name`

Specify your own package name.

Defaults to `ptpd-linuxphc`.

##### `service_name`

The name of the PTPd service.

Defaults to `ptpd`.

##### `service_ensure`

The state of the PTPd service.

Defaults to `running`.

##### `service_enable`

Controls whether the PTPd service starts on boot or not.

Defaults to `true`.

##### `manage_logrotate`

Manages a logrotate rule for the PTPd log and statistics files. This uses the [b4ldr-logrotate](https://github.com/b4ldr/puppet-logrotate) module.

Defaults to `true`.

##### `logrotate_rotate_every`

Passed to the logrotate class, specifying what period to logrotate on.  See the [b4ldr-logrotate](https://github.com/b4ldr/puppet-logrotate) module.

Defaults to `day`.

##### `logrotate_rotate`

Passed to the logrotate class, specifying how many rotation periods.  See the [b4ldr-logrotate](https://github.com/b4ldr/puppet-logrotate) module.

Defaults to `7`.

## Limitations

The module is tested against CentOS 6. It should work in most other flavours, and I'm
happy to accept pull requests for other distros.

## Development

We will accept pull requests from GitHub.
