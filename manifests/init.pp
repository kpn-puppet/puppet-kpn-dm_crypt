# == Class: dm_crypt

class dm_crypt (
  Enum['present', 'absent'] $config_ensure,
  Enum['present', 'absent'] $package_ensure,
  String $package_name,
) {

  unless ("${facts['os']['family']}${facts['os']['release']['major']}" =~ /(RedHat(6|7))/) {
    fail("Module ${module_name} is not supported on ${::facts['os']['family']} ${::facts['os']['release']['major']}.")
  }

  # call the classes that do the real work
  class { '::dm_crypt::install':
    ensure  => $package_ensure,
    package => $package_name,
  }
}
