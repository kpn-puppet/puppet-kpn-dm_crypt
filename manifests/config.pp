# == Class dm_crypt::config
#
# This class is called from dm_crypt
#
define dm_crypt::config (
  $ensure          = $::dm_crypt::config_ensure,
  $disk_device     = undef,
  $filesystem_type = ext4,
  $mount_point     = undef,
  $password        = $::encrypted_secret,
){

    # Create directory tree from $mount_point
  $mount_point.split('/').reduce |$memo, $value| {
    ensure_resources('file', { "${memo}/${value}" => {'ensure' => 'directory',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0755'
    }})
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

