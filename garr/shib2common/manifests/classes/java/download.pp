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

}
