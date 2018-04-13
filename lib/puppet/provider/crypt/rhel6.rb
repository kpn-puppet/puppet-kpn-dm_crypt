# frozen_string_literal: true

Puppet::Type.type(:crypt).provide(:rhel6) do
  # Without initvars commands won't work.
  initvars

  # Make sure we find all commands on CentOS and FreeBSD
  ENV['PATH'] = ENV['PATH'] + ':/usr/bin:/usr/sbin:/bin:/sbin'

  confine osfamily: :redhat
  confine operatingsystemmajrelease: 6
  commands cryptsetup: 'cryptsetup'
  commands mkfs:       'mkfs'
  commands mount:      'mount'
  commands umount:     'umount'

  def password
    puppet_conf = '/etc/puppetlabs/puppet/puppet.conf'
    puppet_conf_hash = ini2hash(puppet_conf)
    certname = puppet_conf_hash['agent']['certname']
    execute("echo #{resource[:password]}| base64 -d | openssl rsautl -decrypt -inkey /etc/puppetlabs/puppet/ssl/private_keys/#{certname}.pem")
  end

  def exists?
    execute("echo #{password}|cryptsetup luksDump --dump-master-key #{resource[:disk_device]}")
    true
  rescue Puppet::ExecutionFailure
    false
  end

  def create
    create_setup
    create_mkfs
    mount("/dev/mapper/#{resource[:name]}", resource[:mount_point])
  end

  def create_setup
    options = "--verbose --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 luksFormat #{resource[:disk_device]}"
    execute("echo #{password}|cryptsetup #{options}")
    system("echo #{password}|cryptsetup luksOpen #{resource[:disk_device]} #{resource[:name]}")
  end

  def create_mkfs
    mkfs('-t', resource[:filesystem_type].to_s, "/dev/mapper/#{resource[:name]}") unless system("blkid /dev/mapper/#{resource[:name]} ")
  end

  def destroy
    umount("/dev/mapper/#{resource[:name]}")
    cryptsetup('-v', 'luksClose', "/dev/mapper/#{resource[:name]}")
    system("echo #{password}|cryptsetup luksRemoveKey #{resource[:disk_device]}")
  end

  def mount_point
    if !system("cryptsetup -v status /dev/mapper/#{resource[:name]} > /dev/null 2>&1")
      false
    elsif system("mountpoint #{resource[:mount_point]} > /dev/null 2>&1")
      resource[:mount_point]
    end
  end

  def mount_point=(value)
    system("echo #{password}|cryptsetup luksOpen #{resource[:disk_device]} #{resource[:name]}")
    mount("/dev/mapper/#{resource[:name]}", value)
  end
end

def i2h_parse_line(line)
  line.strip.split(';').first =~ %r{^\[([a-zA-Z0-9]+)\]$|^([a-zA-Z0-9\.]+)\s*\=\s*([a-zA-Z0-9\.]+)$}
  data = [Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3)]
  data
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
