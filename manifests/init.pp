# == Class: dm_crypt

class dm_crypt (
  Enum['present', 'absent'] $config_ensure,
  Enum['present', 'absent'] $package_ensure,
  String $package_name,
) {

  # call the classes that do the real work
  class { '::dm_crypt::install':
    ensure  => $package_ensure,
    package => $package_name,
  }
}
