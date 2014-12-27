# == Class: shib2idp::java::package
#
# This module downloads and installs Oracle Java Virtual Machine and SDK via a deb package for Debian.
#
# Parameters:
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2common::java::package {
  include shib2common::java::params

  apt_repository { 'java_repository':
    repository_type    => ['deb', 'deb-src'],
    repository_url     => 'http://ppa.launchpad.net/webupd8team/java/ubuntu',
    repository_targets => ['precise', 'main'],
    sources_file       => 'java.list',
    key_name           => 'EEA14886',
    key_file           => 'puppet:///modules/shib2idp/C2518248EEA14886.key',
  }

  package { 'debconf-utils':
    ensure  => installed,
    require => Apt_repository['java_repository'],
  }

  exec {
    'agree-to-java-license':
      command => "/bin/echo -e 'oracle-java7-installer shared/accepted-oracle-license-v1-1 select true\noracle-java7-installer shared/accepted-oracle-license-v1-1 boolean true' | debconf-set-selections",
      unless  => 'debconf-get-selections | grep \'oracle-java7-installer.*shared/accepted-oracle-license-v1-1.*true\'',
      path    => ['/bin', '/usr/bin'],
      require => Package['debconf-utils'];

    'agree-to-jdk-license':
      command => "/bin/echo -e 'oracle-jdk7-installer shared/accepted-oracle-license-v1-1 select true\noracle-jdk7-installer shared/accepted-oracle-license-v1-1 boolean true' | debconf-set-selections",
      unless  => 'debconf-get-selections | grep \'oracle-jdk7-installer.*shared/accepted-oracle-license-v1-1.*true\'',
      path    => ['/bin', '/usr/bin'],
      require => Package['debconf-utils'];
  }

  package {
    'oracle-java7-installer':
      ensure  => installed,
      require => Exec['agree-to-java-license'];

    'oracle-jdk7-installer':
      ensure  => installed,
      install_options => '--force-yes',
      require => Exec['agree-to-jdk-license'];
  }

  # exec { 'update-alternatives':
  #  command => '/usr/sbin/update-java-alternatives -s java-7-oracle',
  #  require => Package['oracle-java7-installer', 'oracle-jdk7-installer'],
  #}

  $java_dir_name = 'java-7-oracle'
  $java_home     = "/usr/lib/jvm/${shib2common::java::params::java_dir_name}"

  file_line {
    'java_environment_rule_1':
       ensure  => present,
       path    => '/etc/environment',
       line    => "JAVA_HOME=${java_home}",
       require => [Package['oracle-java7-installer'], Package['oracle-jdk7-installer']]
  }

}
