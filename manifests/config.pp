# == Class dm_crypt::config
#
# This class is called from dm_crypt
#
class dm_crypt::config (
  $ensure          = $::dm_crypt::config_ensure,
  $disk_device     = $::dm_crypt::disk_device,
  $filesystem_type = $::dm_crypt::filesystem_type,
  $mount_point     = $::dm_crypt::mount_point,
  $password        = $::dm_crypt::password,
){

  # Make this a private class
  assert_private("Use of private class ${name} by ${caller_module_name} not allowed.")

  # Create directory tree from $mount_point
  $mount_point.split('/').reduce |$memo, $value| {
    file { "${memo}/${value}":
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
    "${memo}/${value}"
  }
  # get label name from directory name without the complete path
  if $mount_point =~ /(.*\/)(.*.)/ {
    $base_path = $1
    $label = $2
  }
  # Configure crypt luks partition
  crypt { $label:
    ensure          => $ensure,
    password        => $password,
    name            => $label,
    disk_device     => $disk_device,
    filesystem_type => $filesystem_type,
    mount_point     => $mount_point,
  }
}

