# dm_crypt

## Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [Setup requirements](#setup-requirements)
    * [What dm_crypt affects](#what-dm_crypt-affects)
    * [Beginning with dm_crypt](#beginning-with-dm_crypt)
4. [Usage](#usage)
    * [Parameters](#parameters)
    * [Examples](#examples)
5. [Reference](#reference)
6. [Limitations](#limitations)
7. [Development](#development)

## Overview

This module will create an encrypted partion for a device using dm-crypt cryptsetup.
Be very carefull to keep you secret otherwise your data is never accessable again.

!!!  Backup your secret including the used certificates for the encryption  !!!

## Module Description
This module cerates an encrypted_secret external fact in /opt/puppetlabs/facter/facts.d/encrypted_secret.yaml.
This module creates an encrypted partion on a disk device with the executable cryptsetup.
You need to specify the disk device which will be encrypted.
You need to specitfy the mount point to mount the encrypted partition.
You need to specify the filesystem type to format the encrypted partition.
You need to supply a base64 encrypted password based on the puppet agent certificates.

## Setup

### Setup  Requirements

This module requires:

* [puppetlabs-stdlib](https://github.tooling.kpn.org/kpn-puppet-forge/puppet-puppetlabs-stdlib) (version requirement: >= 4.6.0 <5.0.0)

### What dm_crypt affects

* The package cryptsetup will be installed.
* The directory path of the suplied mountpoint will be created.
* cryptsetup is used to create the encrypted luks device with a key based on the supplied password.
* cryptsetup will open de the device with a label (label will be the last directory of the supplied mountpoint).
* mkfs will format de newly created encrypted partion /dev/mapper/
* the new device will be mounted on the suplied mountpoint.

You have to supply a base64 encrypted password based on the puppet agents certificates to create the partion.
Keep this password on a safe place because it is needed to open and mount the device otherwise you're data is never accessable again.
For example creating a base64 encrypted password based on de puppet agent public key:
echo "my secret passphrase" | openssl rsautl -encrypt -inkey /etc/puppetlabs/puppet/ssl/public_keys/`hostname`.pem -pubin | base64 | tr -d "\n"

There is also a generated fact called `encrypted_secret` that can be used as password. This fact is stored in the file `/opt/puppetlabs/facter/facts.d/encrypted_secret.yaml`.
!!!  Backup this secret including the used certificates for the encryption  !!!


## Usage

### Beginning with dm_crypt

include dm_crypt to install the software package

### Parameters

This module accepts the following parameters:

  String         $config_ensure,
  String         $pacakge_ensure,
  String         $package_name,

#### config_ensure

Type: string
Default: `'present'`
Values: `'present'`, `'absent'`
Description: Ensures that  resource will be created or removed.
Be carefull to remove the resource because any data on the encrypted partition will be lost

#### package_ensure

Type: string
Default: `'present'`
Values: `'present'`, `'absent'`
Description: Ensures that package will be installed or removed.
Be carefull to remove the resource because any data on the encrypted partition will be lost

#### package_name

Type: string
Default: `'cryptsetup'`
Values: any velis sting with the coreect package name
Description: The package that will be installed.

### defined type dm_crypt::config
  This defined type creates the directory path and calls the crypt resource for enabling  encryption on the specified device

### Parameters for dm_crypt config

  String         $disk_device,
  String         $mount_point,
  String         $filesystem_type,
  String         $password,

#### disk_device (required)

Type: string
Default: `undef`
Values: any valid string representing a existing disk device for example /dev/sdb
Description: This parameter contains a tring with the disk device used for the encrypted partition

#### mount_point (required)

Type: string
Default: `undef`
Values: any valid string with a valid abslotu path of the mount point where the encrypted partion will be mounted
Description: This parameter contains the mount point, the last directory of the path will be used as the label for the encrypted luks device

#### filesytem_type (required)

Type: Enum[string]
Default: `ext4`
Values: 'ext4' or 'xfs'
Description: This parameter contains the filesystem type for mkfs to format the new encrypted partion.

#### password (required)

type: string
Default: $encrypted_secret
Values: base64 encrypted string based on the puppet agent certificates
Description: This parameter contains the encrypted password in base64 format encryption based on the puppet agent certificates
you can supply this password as external fact encrypted_secret

### Examples

#### Example 1: Setting the default values for the module

```puppet
  $encrypted_secret = 'QyY9BNdBSvee5q2H+CzDr8BsSvxPkrSLzvEro8FnwJ8EBCk5/DtGrSU/diBkUHXGqezggZnJumlLwwXIXG+G1/7X+VDwSIoKqnTq/VKzzve8t1My8fZnbuQLS/iTac06umAkqvJbMCc8R+Kl9a8sovxnZa3d9rTu4eMLb5hnWfpFpv9mK2XbbkCsWJqdzDv+XSsEr6nnnyxzsIJ8F8O2SxCvJkR0gHpVdBmNREMbEdAqVXQSeV1eKr4rNitM1CUZq/yi62yjbxQGAj7epZGe0eu6DGFXuoZqh/eAnC4e5XaWh3XxQAFq30vlY953G9yR3l+bFg/MFRmZU4vwaHvWh1D3Bn9O9c8WiW6lc0kUgm/8NfOejPgipOL3r7VhbNdQpyP/rhvvagyuM00dAukd5ATFbi2AnM3C9JQfws8glN+jHOR01N6o3OynfbE3SZrq229XTZM9m3rRWUglbPQFUlNH3M+LjNvdrQGlNVr/3utGUhfUv4OzZz9B5JiMpYO8nBjvbhYeLttOnRJ5G10BSd/9vufJWOh1FkGoVnkBknzjzhc3cRe08uI2T6r6lD4DKpujK0rzgcR15U/fg9BBZLGgD2+vUVvb95SxNY9bgVtk7ZhBYG065828i1omt7C4F7rkWPtcSovts9U1OAjKqsQ5yfFlmqjjRwr9gwyFWbE='

  class { 'dm_crypt':
    ensure_package => 'present',
    package_name   => 'cryptsetup',
  }
  dm_crypt::config { postgresDB:
    ensure          => present,
    disk_device     => "/dev/mapper/vg_postgress-postgresDB",
    mount_point     => /media/postgresDB,
    filesystem_type => ext4,
    password        => $::encrypted_secret,
  }
```

#### Example 2: Use generated encrypted_secret fact

```puppet
  include dm_crypt
  dm_crypt::config { postgresDB:
    ensure          => present,
    disk_device     => "/dev/mapper/vg_postgress-postgresDB",
    mount_point     => /media/postgresDB,
    filesystem_type => ext4,
    password        => $::facts['encrypted_secret'],
  }
```

## Reference

classes:

- [dm_crypt](#dmcrypt)

defined type:
- [dm_crypt::config](#dm_crypt::config)

types:

* lib/puppet/type/crypt.rb

facts:
* lib/puppet/facter/encrypted_secret.rb

providers:

* lib/puppet/providers/crypt/rhel7.rb
* lib/puppet/providers/crypt/rhel6.rb

## Limitations

This module works only on:

* RedHat 6
* RedHat 7

## Development

You can contribute by submitting issues, providing feedback and joining the discussions.

Go to: `https://github.com/kpn-puppet/puppet-kpn-dm_crypt`

If you want to fix bugs, add new features etc:

* Fork it
* Create a feature branch ( git checkout -b my-new-feature )
* Apply your changes and update rspec tests
* Run rspec tests ( bundle exec rake spec )
* Commit your changes ( git commit -am 'Added some feature' )
* Push to the branch ( git push origin my-new-feature )
* Create new Pull Request
