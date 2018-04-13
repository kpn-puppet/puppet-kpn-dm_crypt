# frozen_string_literal: true

require 'spec_helper_acceptance'

package_name = (fact('os.release.major') == '6') ? 'cryptsetup-luks' : 'cryptsetup'

describe 'Dm_crypt', if: fact('os.family') == 'RedHat' do
  context 'when remove dmcrypt if present' do
    removepp = <<-PP
      package { '#{package_name}':
        ensure => absent,
      }
    PP

    # Run it twice and test for idempotency
    apply_manifest(removepp, catch_failures: true)
    apply_manifest(removepp, catch_changes: true)

    describe package(package_name) do
      it { is_expected.not_to be_installed }
    end
  end

  context 'with default parameters' do
    # Using puppet_apply as a helper
    pp = <<-PP
      class { 'dm_crypt':
        config_ensure   => 'present',
        disk_device     => '/dev/sdb',
        mount_point     => '/apps/postgresDB',
        filesystem_type => 'ext4',
      }
    PP
    it 'works idempotently with no errors' do
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package(package_name) do
      it { is_expected.to be_installed }
    end
  end

  pp = <<-PP
    class { 'dm_crypt':
      config_ensure   => 'absent',
      disk_device     => '/dev/sdb',
      mount_point     => '/apps/postgresDB',
      filesystem_type => 'ext4',
    }
  PP
  context 'with remove encrypted partition' do
    it 'works idempotently with no errors' do
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
