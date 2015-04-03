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
  
  if ($::disable_reboot) {
    file { '/etc/apt/apt.conf.d/50unattended-upgrades':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("shib2common/50unattended-upgrades.erb"),
      require => Package['unattended-upgrades'],
    }
  }
  
  file { '/usr/share/unattended-upgrades/20auto-upgrades-disabled':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => join(['APT::Periodic::Update-Package-Lists "1";',
                     'APT::Periodic::Unattended-Upgrade "1";'], "\n"),
    require => Package['unattended-upgrades'],
  }
}