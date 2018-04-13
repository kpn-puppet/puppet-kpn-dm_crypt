# frozen_string_literal: true

SUPPORTED_FACTS = [
  { 'os' => {
    'name' => 'CentOs',
    'family' => 'RedHat',
    'release' => {
      'major' => '7',
      'minor' => '2',
      'full' => '7.2.1511',
    },
    'package_name' => 'cryptsetup',
  } },
  { 'os' => {
    'name' => 'CentOs',
    'family' => 'RedHat',
    'release' => {
      'major' => '6',
      'minor' => '3',
      'full' => '6.3.834',
    },
    'package_name' => 'cryptsetup_luks',
  } },
].freeze
UNSUPPORTED_FACTS = [
  { 'os' => {
    'name' => 'windows',
    'family' => 'windows',
    'release' => {
      'major' => '2012 R2',
      'minor' => '2012',
      'full' => '2012 R2',
    },
  } },
].freeze
