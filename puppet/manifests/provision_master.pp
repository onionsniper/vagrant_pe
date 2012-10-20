class { 'staging': path => '/var/tmp', } 

class {'puppet_enterprise':
  isMaster => 'true',
  master_ip => '192.168.9.9',
  master_name => 'puppet.vagrant',
}
