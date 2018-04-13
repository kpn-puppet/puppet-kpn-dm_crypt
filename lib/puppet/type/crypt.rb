# frozen_string_literal: true

Puppet::Type.newtype(:crypt) do
  desc <<-DOC
    Creates an fully encrypted Luks partition.
    Example:
    crypt { 'postgressDB':
      ensure          => present,
      name            => 'postgressDB',
      disk_device     => '/dev/sdb',
      mount_point     => '/apps/postgresDB',
      filesystem_type => 'ext4',
      password        => 'secret',
    }
  DOC
  validate do
    if self[:ensure] == :present && self[:disk_device].nil?
      raise('disk_device is required when ensure is present')
    end
  end
  ensurable do
    defaultvalues
    defaultto :present
  end
  newparam(:name, namevar: true) do
    desc 'An arbitrary name used as the label for this device.'
  end
  newparam(:disk_device) do
    desc 'The device to be encrypted.'
    validate do |value|
      raise("Invalid device #{value}") unless Pathname.new(value).absolute?
    end
  end
  newproperty(:mount_point) do
    desc 'Mount point for the encrypted device.'
    validate do |value|
      raise("Invalid device #{value}") unless Pathname.new(value).absolute?
    end
  end
  newparam(:password) do
    desc 'Password to create and open the encrypted device'
  end
  newparam(:filesystem_type) do
    desc 'The filesystem type for this device.'
    newvalues(:xfs, :ext4)
  end
end
