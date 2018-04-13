# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'Dm_crypt', if: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  describe 'unsupported distributions and OSes' do
    it 'this will fail' do
      pp = <<-PP
      class { 'dm_crypt': }
      PP
      expect(apply_manifest(pp, expect_failures: true).stderr).to match(%r{is not supported}i)
    end
  end
end
