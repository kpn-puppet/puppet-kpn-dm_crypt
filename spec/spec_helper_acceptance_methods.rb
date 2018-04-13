# frozen_string_literal: true

def clone_dependent_modules
  fixtures = YAML.load_file('.fixtures.yml')['fixtures']
  fixtures['repositories'].each do |module_name, value|
    ssh_link = value.is_a?(Hash) ? value['repo'] : value
    ref = (value.is_a?(Hash) && value.key?('ref')) ? value['ref'] : 'master'
    system("git clone --branch #{ref} #{ssh_link} spec/fixtures/modules/#{module_name}")
  end
end

def install_dependent_modules
  fixtures = YAML.load_file('.fixtures.yml')['fixtures']
  fixtures['repositories'].each do |module_name, _value|
    copy_module_to(hosts, source: "./spec/fixtures/modules/#{module_name}", module_name: module_name)
  end
end
