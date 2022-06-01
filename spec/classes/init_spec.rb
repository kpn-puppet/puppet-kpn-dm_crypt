# frozen_string_literal: true

require 'spec_helper'

describe 'dm_crypt' do
  default_params = {
    'disk_device' => '/dev/sdb',
    'filesystem_type' => 'ext4',
    'mount_point' => '/data/storage',
  }

  test_on = {
    supported_os: [
      {
        'operatingsystem' => 'RedHat',
        'operatingsystemrelease' => %w[5],
      },
    ],
  }
  on_supported_os(test_on).each do |os, facts|
    describe "on unsupported operating system #{os}" do
      let(:params) { default_params }
      let(:facts) { facts }

      it { is_expected.to raise_error(Puppet::Error, %r{Module dm_crypt is not supported}) }
    end
  end

  on_supported_os.each do |os, facts|
    describe "on supported operating system #{os}" do
      let(:facts) { facts }

      describe 'without parameters' do
        let(:params) { {} }

        it { is_expected.to raise_error(Puppet::Error, %r{Error}) }
      end

      describe 'with default parameters' do
        let(:params) { default_params }

        it { is_expected.to compile.with_all_deps }

        # Check classes and relations
        it { is_expected.to contain_class('dm_crypt') }
        it { is_expected.to contain_class('dm_crypt::install') }
        it { is_expected.to contain_class('dm_crypt::config') }

        # Check common resources
        it { is_expected.to contain_file('/data').with_ensure('directory') }
        it { is_expected.to contain_file('/data').with_owner('root') }
        it { is_expected.to contain_file('/data').with_group('root') }
        it { is_expected.to contain_file('/data').with_mode('0755') }
        it { is_expected.to contain_file('/data/storage').with_ensure('directory') }
        it { is_expected.to contain_file('/data/storage').with_owner('root') }
        it { is_expected.to contain_file('/data/storage').with_group('root') }
        it { is_expected.to contain_file('/data/storage').with_mode('0755') }
        it { is_expected.to contain_crypt('storage') }

        if facts[:os]['release']['major'] == '6'
          it { is_expected.to contain_package('cryptsetup-luks') }
        else
          it { is_expected.to contain_package('cryptsetup') }
        end
      end
    end
  end
end
