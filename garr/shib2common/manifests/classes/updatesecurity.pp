# == Class: shib2common::updatesecurity
#
# This configures unattended upgrades to perform security updated automatically.
# Parameters:
# +disable_reboot+:: This parameter permits to specify if all packages requiring a reboot must
#                    be excluded from security updates.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2common::updatesecurity (
  $disable_reboot          = true,
) {
  
  exec { 'enable-unattended-upgrades':
      command => "/bin/echo -e 'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true' | debconf-set-selections",
      unless  => 'debconf-get-selections | grep \'unattended-upgrades.*unattended-upgrades/enable_auto_updates.*true\'',
      path    => ['/bin', '/usr/bin'],
      require => Package['debconf-utils'];
  }
  
  package { 'unattended-upgrades':
     ensure => 'present',
     require => Exec['enable-unattended-upgrades'],
  }
  
  file {
    '/etc/apt/apt.conf.d/50unattended-upgrades':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2common/50unattended-upgrades.erb"),
      require => Package['unattended-upgrades'];      
  }
}
