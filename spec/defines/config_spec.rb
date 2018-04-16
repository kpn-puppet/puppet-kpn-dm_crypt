# frozen_string_literal: true

require 'spec_helper'
require_relative '../versions.rb'

describe 'dm_crypt::config', type: :define do
  SUPPORTED_FACTS.each do |facts|
    describe "on supported operating system #{facts['os']['family']} #{facts['os']['release']['major']}" do
      let(:facts) { facts }
      let(:title) { 'pgdata' }
      let(:params) do
        {
          'ensure'          => 'present',
          'disk_device'     => '/dev/sdb',
          'filesystem_type' => 'ext4',
          'mount_point'     => '/media/pgdata',
          'password'        => facts['encrypted_secret'],
        }
      end

      context 'with default parameters' do
        # it { is_expected.to compile }
        it { is_expected.to contain_crypt('pgdata') }
      end
    end
  end
end
