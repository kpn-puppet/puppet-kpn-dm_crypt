# frozen_string_literal: true

require 'spec_helper'
require_relative '../versions.rb'

describe 'Dm_crypt' do
  default_params = {
    'config_ensure'  => 'present',
    'package_ensure' => 'present',
    'package_name'   => 'cryptsetup_luks',
  }

  UNSUPPORTED_FACTS.each do |facts|
    describe "on unsupported operating system #{facts['os']['family']} #{facts['os']['release']['major']}" do
      let(:params) { default_params }
      let(:facts) { facts }

      it { is_expected.to raise_error(Puppet::Error, %r{Module dm_crypt is not supported}) }
    end
  end

  SUPPORTED_FACTS.each do |facts|
    describe "on supported operating system #{facts['os']['family']} #{facts['os']['release']['major']}" do
      let(:facts) { facts }

      describe 'without parameters' do
        let(:params) { {} }

        it { is_expected.to contain_class('dm_crypt') }
        it { is_expected.to contain_class('dm_crypt::install') }
      end

      describe 'with default parameters' do
        if facts['os']['release']['major'] == '6'
          let(:params) do
            {
              'config_ensure'  => 'present',
              'package_ensure' => 'present',
              'package_name'   => 'cryptsetup-luks',
            }
          end
        else
          let(:params) do
            {
              'config_ensure'  => 'present',
              'package_ensure' => 'present',
              'package_name'   => 'cryptsetup',
            }
          end
        end

        it { is_expected.to compile.with_all_deps }
        # Check classes and relations
        it { is_expected.to contain_class('dm_crypt') }
        it { is_expected.to contain_class('dm_crypt::install') }
        if facts['os']['release']['major'] == '6'
          it { is_expected.to contain_package('cryptsetup-luks') }
        else
          it { is_expected.to contain_package('cryptsetup') }
        end
      end
    end
  end
end
