define idpfirewall::firewall (
  $iptables_enable_network = undef,
) {
  
  # Clear any existing rules and make sure that only rules defined in Puppet exist on the machine
  #resources { "firewall":
  #  purge => true,
  #}

  Firewall {
    before => Class['idpfirewall::post'],
    require => Class['idpfirewall::pre'],
  }

  class { ['idpfirewall::pre','idpfirewall::post']: }

  class { 'firewall': }

  if($iptables_enable_network){
    firewall { '100 redirect 80 to 8080 for localhost':
      table    => 'nat',
		  chain    => 'OUTPUT',
		  outiface => 'lo',
		  proto    => 'tcp',
		  dport    => '80',
		  jump     => 'REDIRECT',
		  toports  => '8080'
    } ->
    firewall { '104 allow SSH':
      port   => 22,
      proto  => 'tcp',
      action => 'accept',
      source => $iptables_enable_network,
    }->
    firewall { '105 allow NRPE':
      port   => [1000, 5666],
      proto  => 'tcp',
      action => 'accept',
      source => $iptables_enable_network,
    }->
    firewall { '106 allow LDAP and LDAPS':
      port   => [389, 636],
      proto  => 'tcp',
      action => 'accept',
      source => $iptables_enable_network,
    }
  }
  else{
    firewall { '100 redirect 80 to 8080 for localhost':
      table    => 'nat',
      chain    => 'OUTPUT',
      outiface => 'lo',
      proto    => 'tcp',
      dport    => '80',
      jump     => 'REDIRECT',
      toports  => '8080'
    } ->
    firewall { '104 allow SSH':
      port   => 22,
      proto  => 'tcp',
      action => 'accept',
    }->
    firewall { '105 allow NRPE':
      port   => [1000, 5666],
      proto  => 'tcp',
      action => 'accept',
    }->
    firewall { '106 allow LDAP and LDAPS':
      port   => [389, 636],
      proto  => 'tcp',
      action => 'accept',
      source => $iptables_enable_network,
    }
  }

}
