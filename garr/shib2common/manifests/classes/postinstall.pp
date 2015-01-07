# == Class: shib2common::postinstall
#
# This class execute all postinstall operations.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2common::postinstall() {

  # Exec to restart apache after installations and configuration
  # Exec to restart tomcat and apache after installations and configuration
  $curtomcat = $::tomcat::curtomcat
  exec {
    #'shib2-tomcat-restart':
    #  command     => "/usr/sbin/service ${curtomcat} restart",
    #  refreshonly => true;

    #'shib2-apache-restart':
    #  command     => '/usr/sbin/service apache2 restart',
    #  refreshonly => true;

    'shib2-shibd-restart':
      command     => '/usr/sbin/service shibd restart',
      refreshonly => true;
  }

}
