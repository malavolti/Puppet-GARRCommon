# == Class: shib2common::certificate
#
# This class checks the server certificates for HTTPS and install them on the Puppet agent machine.
# This class is also responsible to install new certificates when they are available to substitute
# expired ones on the IdP machine.
#
# The files used as certificates for all the IdPs are in the files/certs directory in this module
# folders' tree. Each puppet agent has a couple of certificate files available in that directory:
# - {puppetagenthostname}-key-server.pem: the secret key of the client's certificate
# - {puppetagenthostname}-cert-server.pem: the public key of the client's certificate
#
# This class also registers a set of actions to be executed every night. These instructions check
# the expiration date of the certificate and if it is about to expire (less than 1 month from the
# current date) send an email to the address specified notifying the situation.
#
# Parameters:
# +idpfqdn+:: This parameters must contain the fully qualified domain name of the IdP. This name must be the exact name used by client users to access the machine over the Internet. This FQDN, in fact, will be used to determine the CN of the certificate used for HTTPS. If the name is not identical with the server name specified by the client, the client's browser will raise a security exception.
# +keystorepassword+:: This parameter permits to specify the keystore password used to protect the keystore file on the IdP server.
# +mailto+:: The email address to be notified when the certificate used for HTTPS is about to expire. If no email address is specified, no mail warning will be sent.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2common::certificate (
  $hostfqdn          = 'idp.example.org',
  $keystorepassword = 'puppetpassword',
  $mailto           = undef,
  $nagiosserver     = undef,
) {

  #$curtomcat = $::tomcat::curtomcat
  $cert_directory = '/root/certificates'
  $idp_home       = '/opt/shibboleth-idp'

  host {
   "localhost":
      ensure => 'present',   
      target => '/etc/hosts',
      ip => '127.0.0.1',

   ;

    "$fqdn":
      ensure => 'present',
      target => '/etc/hosts',
      ip => '127.0.1.1',
      host_aliases => ["$hostname"]
  }

  file {
    $cert_directory:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0600';

    "${cert_directory}/key-server.pem":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      source  => "puppet:///modules/shib2common/certs/${hostname}-key-server.pem",
      require => File[$cert_directory],
      notify  => Service['httpd'];

    "${cert_directory}/cert-server.pem":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      source  => "puppet:///modules/shib2common/certs/${hostname}-cert-server.pem",
      require => File[$cert_directory],
      notify  => Service['httpd'];
  }

  # Install certificate files. They should be present in ${cert_directory} directory and
  # should be named key-server.pem and ${hostfqdn}.pem
  #download_file { "${cert_directory}/Terena-chain.pem":
  #  url     => 'https://ca.garr.it/mgt/Terena-chain.pem',
  #  require => File[$cert_directory],
  #  notify  => Service['httpd'],
  #}
  file { "${cert_directory}/Terena-chain.pem":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/shib2common/certs/Terena-chain.pem",
    require => File[$cert_directory],
    notify  => Service['httpd'],
  }

  # if nagiosserver is set, the activities to verify certificate expiration
  # are executed by the nagios server (to standardize the monitoring and
  # notification processes).
  if (!$nagiosserver and $mailto != '') {
    file { "/etc/cron.daily/expiry":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("shib2common/expiry.sh.erb"),
      require => File["${cert_directory}"];
    }

  }

}
