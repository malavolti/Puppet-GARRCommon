# == Class: tomcat::tomcat6
#
# Base class from which others inherit. It shouldn't be necessary to include it
# directly.
# 
# Class variables:
# - +$log4j_conffile+:: location of an alternate log4j.properties file. Default is puppet:///modules/tomcat/conf/log4j.rolling.properties
#
class tomcat::tomcat6 {
  user { "tomcat":
    ensure => present,
  }

  package {
    ["liblog4j1.2-java", "libcommons-logging-java", "libtomcat6-java"]:
      ensure => present;
  
    ["tomcat6-common", "tomcat6"]:
      ensure => present;

  }

  service { "tomcat6":
    ensure  => running,
    enable  => true,
    require => Package["tomcat6"],
  }

  $tomcat_home = '/usr/share/tomcat6'
  $catalina_out = '/var/log/tomcat6/catalina.out'
  $catalina_home = '/var/lib/tomcat6'
  
  file { "log4j.properties":
    path => "${catalina_home}/conf/log4j.properties",
    source => $::log4j_conffile ? {
      default => $::log4j_conffile,
      ""      => "puppet:///modules/tomcat/conf/log4j.rolling.properties",
    },
    require => Package["tomcat6"],
  }
  
  # Verify that /etc/environment has the correct lines
  file_line {
    'tomcat6_environment_rule_1':
      ensure => present,
      path => '/etc/environment',
      line => "TOMCAT_HOME=${tomcat_home}",
      require => Package["tomcat6"];
  
    'tomcat6_environment_rule_2':
      ensure => present,
      path => '/etc/environment',
      line => "CATALINA_OUT=${catalina_out}",
      require => Package["tomcat6"];
  
    'tomcat6_environment_rule_3':
      ensure => present,
      path => '/etc/environment',
      line => "CATALINA_HOME=${catalina_home}",
      require => Package["tomcat6"];
  }
  
}
