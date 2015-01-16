# == Class: tomcat::tomcat7
#
# Base class from which others inherit. It shouldn't be necessary to include it
# directly.
# 
# Class variables:
# - +$log4j_conffile+:: location of an alternate log4j.properties file. Default is puppet:///modules/tomcat/conf/log4j.rolling.properties
#
class tomcat::tomcat7 {
  user { "tomcat":
    ensure => present,
  }

  package {
    ["liblog4j1.2-java", "libcommons-logging-java", "libtomcat7-java"]:
      ensure  => present,
      require => Class['shib2common::java::package'];
  
    ["tomcat7-common", "tomcat7"]:
      ensure  => present,
      require => Class['shib2common::java::package'];
  }

  service { "tomcat7":
    ensure  => running,
    enable  => true,
    require => Package["tomcat7"],
  }

  $tomcat_home = '/usr/share/tomcat7'
  $catalina_out = '/var/log/tomcat7/catalina.out'
  $catalina_home = '/var/lib/tomcat7'
  
  # Default JVM options
  file { "log4j.properties":
    path => "${catalina_home}/conf/log4j.properties",
    source => $::log4j_conffile ? {
      default => $::log4j_conffile,
      ""      => "puppet:///modules/tomcat/conf/log4j.rolling.properties",
    },
    require => Package["tomcat7"],
    before  => Service["tomcat7"],
  }
  
  # Verify that /etc/environment has the correct lines
  file_line {
    'tomcat7_environment_rule_1':
      ensure => present,
      path => '/etc/environment',
      line => "TOMCAT_HOME=${tomcat_home}",
      require => Package["tomcat7"];
  
    'tomcat7_environment_rule_2':
      ensure => present,
      path => '/etc/environment',
      line => "CATALINA_OUT=${catalina_out}",
      require => Package["tomcat7"];
  
    'tomcat7_environment_rule_3':
      ensure => present,
      path => '/etc/environment',
      line => "CATALINA_HOME=${catalina_home}",
      require => Package["tomcat7"];
  }
  
}
