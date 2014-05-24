# == Class: shib2common::instance
#
# This performs all common configurations and installations required for GARR shib modules.
# Parameters:
# +install_apache+:: This parameters specifies wether apache httpd should be installed.
# +install_tomcat+:: This parameter specifies wether apache tomcat should be installed.
# +configure_admin+:: This parameter specifies wether the tomcat admin console should be installed.
# +tomcat_admin_password+:: This parameter specifies the password for the tomcat user admin.
# +tomcat_manager_password+:: This parameter specifies the password for the tomcat user manager.
# +hostfqdn+:: This parameter contains the FQDN used as servername in apache.
# +keystorepassword+:: The password to be used to secure the keystore.
# +mailto+:: This paramenter contains a mailto to be specified in apache httpd configuration.
# +nagiosserver+:: The URL or name of the nagios server to be used for monitoring.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
define shib2common::instance(
  $install_apache          = undef,
  $apache_doc_root         = undef,
  $install_tomcat          = undef,
  $configure_admin         = undef,
  $tomcat_admin_password   = undef,
  $tomcat_manager_password = undef,
  $hostfqdn                = 'idp.example.org',
  $keystorepassword        = 'puppetpassword',
  $mailto                  = undef,
  $nagiosserver            = undef,
) {

    class { 'shib2common::certificate':
        hostfqdn         => $hostfqdn,
        keystorepassword => $keystorepassword,
        mailto           => $mailto,
        nagiosserver     => $nagiosserver,
    }

    class { 'shib2common::prerequisites':
      install_apache          => $install_apache,
      apache_doc_root         => $apache_doc_root,
      install_tomcat          => $install_tomcat,
      configure_admin         => $configure_admin,
      tomcat_admin_password   => $tomcat_admin_password,
      tomcat_manager_password => $tomcat_manager_password,
      hostfqdn                => $hostfqdn,
      mailto                  => $mailto,
    }

    class { 'shib2common::postinstall': }

}
