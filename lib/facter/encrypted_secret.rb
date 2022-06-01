# frozen_string_literal: true

require 'facter'
require 'socket'
require 'yaml'

Facter.add('encrypted_secret') do
  confine kernel: :Linux
  setcode do
    data = {}
    puppet_conf = '/etc/puppetlabs/puppet/puppet.conf'
    es_yaml = '/opt/puppetlabs/facter/facts.d/encrypted_secret.yaml'

    # Search yaml file
    if File.file?(es_yaml)
      data = YAML.load_file(es_yaml)
      data = {} if data == false || data.nil?
    end

    # Generate password and save as fact
    unless data.key?('encrypted_secret')
      # lookup public key file name
      puppet_conf_hash = ini2hash(puppet_conf)
      certname = puppet_conf_hash['agent']['certname']
      public_key = "/etc/puppetlabs/puppet/ssl/public_keys/#{certname}.pem"
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

def i2h_parse_line(line)
  line.strip.split(';').first =~ %r{^\[([a-zA-Z0-9]+)\]$|^([a-zA-Z0-9\.]+)\s*\=\s*([a-zA-Z0-9\.]+)$}
  [Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3)]
end

def ini2hash(filename)
  ini = {}
  cur_section = nil
  File.open(filename).each do |line|
    data = i2h_parse_line(line)
    cur_section = data[0] unless data[0].nil?
    ini[cur_section] = {} unless data[0].nil?
    ini[cur_section].merge!(data[1] => data[2]) if data[1]
  end
  ini
end
