# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html

# Install required packages
class { 'dm_crypt':
  config_ensure  => 'present',
  package_ensure => 'present',
  package        => 'cryptsetup'
}
# Configure crypt luks partition including creation of path
# dm_crypt::config
dm_crypt::config { 'postgresDB':
  ensure          => present,
  disk_device     => '/dev/mapper/vg_postgress-postgresDB',
  mount_point     => '/media/postgresDB',
  filesystem_type => 'ext4',
  password        => $::encrypted_secret,
}
#crypt { 'postgresDB':
#  ensure      => 'present',
#  password    => $::encrypted_secret,
#  name        => 'postgresDB',
#  disk_device => '/dev/sdk',
#}


