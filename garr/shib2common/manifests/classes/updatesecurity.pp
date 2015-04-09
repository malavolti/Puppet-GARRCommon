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
  
  package { 'unattended-upgrades':
     ensure => 'present',
  }
  
  file {
    '/etc/apt/apt.conf.d/50unattended-upgrades':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2common/50unattended-upgrades.erb"),
      require => Package['unattended-upgrades'];
      
    '/usr/share/unattended-upgrades/20auto-upgrades-disable':
      ensure => absent,
      require => Package['unattended-upgrades'];

    '/usr/share/unattended-upgrades/20auto-upgrades':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => join(['APT::Periodic::Update-Package-Lists "1";',
                       'APT::Periodic::Unattended-Upgrade "1";'], "\n"),
      require => Package['unattended-upgrades'];
  }
}
