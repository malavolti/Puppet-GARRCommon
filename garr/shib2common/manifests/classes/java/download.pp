# == Class: shib2idp::java::download
#
# This module downloads and installs Oracle Java Virtual Machine and SDK.
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
class shib2common::java::download {

  download_file { $::shib2idp::java::params::java_home:
    url     => 'http://server/jre-7u15-linux-i586.tar.gz',
    extract => 'tar.gz',
  }

  # exec { "update-alternatives":
  #  command => "/usr/sbin/update-java-alternatives -s java-7-oracle",
  #  require => Package["oracle-java7-installer", "oracle-jdk7-installer"],
  #}

  file_line {
    'java_environment_rule_1':
      ensure  => present,
      path    => '/etc/environment',
      line    => "JAVA_HOME=${::shib2idp::java::params::java_home}",
      require => Download_file[$::shib2idp::java::params::java_home];

    'java_environment_rule_2':
      ensure  => present,
      path    => '/etc/environment',
      line    => 'JAVA_OPTS="-Djava.awt.headless=true -Xmx512M -XX:MaxPermSize=128m"',
      require => Download_file[$::shib2idp::java::params::java_home];
  }

}
