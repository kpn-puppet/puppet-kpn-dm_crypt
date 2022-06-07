# == Class: dm_crypt

class dm_crypt (
  String $disk_device,
  String $mount_point,
  String $filesystem_type,
  String $password,
  Enum['present', 'absent'] $config_ensure,
  Enum['present', 'absent'] $package_ensure,
  String $package_name,
) {

  unless ("${facts['os']['family']}${facts['os']['release']['major']}" =~ /(RedHat[6-8])/) {
    fail("Module ${module_name} is not supported on ${::facts['os']['family']} ${::facts['os']['release']['major']}.")
  }

  # call the classes that do the real work
  class { '::dm_crypt::install':
    ensure  => $package_ensure,
    package => $package_name,
  }
  -> class { '::dm_crypt::config':
    ensure          => $config_ensure,
    disk_device     => $disk_device,
    mount_point     => $mount_point,
    filesystem_type => $filesystem_type,
    password        => $password,
  }
}
