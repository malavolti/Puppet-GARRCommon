class idpfirewall::pre{

  Firewall {
    require => undef,
  }

  # Default firewall rules
  firewall {'000 accept all localhost traffic':
    action      => 'accept',
    destination => '127.0.0.1',
  }->
  firewall { '001 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }->
  firewall { '002 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '003 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }->
  firewall { '004 allow HTTP HTTPS access':
    port   => [80, 8080, 443, 8443],
    proto  => 'tcp',
    action => 'accept',
  }

}
  
