# frozen_string_literal: true

require 'facter'
require 'socket'
require 'yaml'

Facter.add('encrypted_secret') do
  confine kernel: :Linux
  setcode do
    data = {}
    es_yaml = '/opt/puppetlabs/facter/facts.d/encrypted_secret.yaml'

    # Search yaml file
    if File.file?(es_yaml)
      data = YAML.load_file(es_yaml)
      data = {} if data == false || data.nil?
    end

    # Generate password and save as fact
    unless data.key?('encrypted_secret')
      # Generate a public key using the host cert
      public_key = Puppet.settings[:hostpubkey].to_s
      unless File.file?(public_key)
        certificate = "#{Puppet.settings[:certdir]}/#{Facter.value(:fqdn).downcase}.pem"
        Facter::Core::Execution.execute("openssl x509 -pubkey -noout -in #{certificate} > #{public_key}")
      end
      command = "dd if=/dev/urandom bs=512 count=200 | tr -dc _A-Z-a-z-0-9 | head -c${1:-64} | openssl rsautl -encrypt -inkey #{public_key} -pubin | base64 | tr -d \"\n\""
      password = Facter::Core::Execution.execute(command)
      data = data.merge('encrypted_secret' => password)
      # Save fact to yaml file
      out_file = File.new(es_yaml, 'w')
      out_file.puts(data.to_yaml)
      out_file.close
    end

    data['encrypted_secret']
  end
end
