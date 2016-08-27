# ptpd

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with ptpd](#setup)
    * [What ptpd affects](#what-ptpd-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ptpd](#beginning-with-ptpd)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Manages the Precision Time Protocol (PTP) version 2 software, PTPd.


## Module Description

This Puppet class is expected to work with ptpd version 2.3.2 with Linux PHC support, or later.
At the time of writing this was not merged into mainline, nor where there packages for it.

So, you need to build your own from source, which can be found here:

https://github.com/wowczarek/ptpd/tree/wowczarek-2.3.2-hwtest

## Setup

### What ptpd affects

This module will manage the configuration files for ptpd, namely /etc/ptpd.conf, along with the
associated service. It will also install a ptpd package, which defaults to 'ptpd-linuxphc', which
is the name of the package that's built from the source tree above. Note that this will be quite
different to any older ptpd daemons in some distributions.

### Beginning with ptpd

Resource-like syntax is probably the better option, as you will need to configure the module:

~~~ puppet
class { 'ptpd:' }
~~~

or if all your parameters are in Hiera:

~~~ puppet
include ptpd
~~~

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

### Classes

#### Public Classes

* `ptpd`: Class that installs and configures ptpd.

### Parameters

#### ptpd

##### `package_name`

Specify your own package name.

## Limitations

The module is tested against CentOS 6. It should work in most other flavours, and I'm
happy to accept pull requests for other distros.

## Development

We will accept pull requests from GitHub.
