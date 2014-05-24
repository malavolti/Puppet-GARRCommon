class idpfirewall::post{
  firewall{ '998 reject FORWARD':
    chain  => 'FORWARD',
    proto  => 'tcp',
    action => 'reject',
  }->
  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }
}
