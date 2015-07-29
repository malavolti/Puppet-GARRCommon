# == Class: shib2common::prerequisites
#
# This class execute all postinstall operations.
#
# Parameters:
# +install_apache+:: This parameters specifies wether apache httpd should be installed.
# +install_tomcat+:: This parameter specifies wether apache tomcat should be installed.
# +configure_admin+:: This parameter specifies wether the tomcat admin console should be installed.
# +tomcat_admin_password+:: This parameter specifies the password for the tomcat user admin.
# +tomcat_manager_password+:: This parameter specifies the password for the tomcat user manager.
# +hostfqdn+:: This parameter contains the FQDN used as servername in apache.
# +mailto+:: This paramenter contains a mailto to be specified in apache httpd configuration.
#
# Actions:
#
# Requires:
#
# Sample Usage:
# This class file is not called directly.
#
class shib2common::prerequisites(
  $install_apache          = false,
  $apache_doc_root         = '/var/www',
  $install_tomcat          = false,
  $configure_admin         = false,
  $tomcat_admin_password   = '',
  $tomcat_manager_password = '',
  $hostfqdn                = 'idp.example.org',
  $mailto                  = 'support@garr.it',
) {
  
    # Install packages for Augeas, used by Puppet to configure GARR software
		class { 'shib2common::augeas':
		  #augeas_version      => '0.10.0-1~bpo60+3',
		  #augeas_ruby_version => '0.3.0-1.1',
		  augeas_version      => 'present',
		  augeas_ruby_version => 'present',
		}

    exec { 'apt-get update':
      command     => 'apt-get update',
      path        => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    }
 
    # Execute an "apt-get update" and then install all packages
    Exec['apt-get update'] -> Package<| |>
    
    # Install the packages "unzip" and "wget" before execute any Download_file
    Package['unzip', 'wget'] -> Download_file <| |>

    # Install "ruby-mysql" package before execute any Execute_mysql
	 Package['ruby-mysql'] -> Execute_mysql <| |>
	
    package { [
        'openssl',
        'ntp',
        'expat',
        'ca-certificates',
        'unzip',
        'wget',
        'git',
        'rsyslog',
        'ruby-mysql',
        'expect']:
      ensure => installed,
    }

    if ($install_apache == true) {
        # Install Apache2 Web server and default modules for Prefork version.

        if ($operatingsystem == 'Ubuntu' and $operatingsystemmajrelease == '14.04'){
            package { 'apache2-utils':
               ensure => installed, 
            }
        }

        class { 'apache':
            default_vhost => false,
            mpm_module    => 'prefork',
            require       => [Host ['localhost'], Host ["$fqdn"]],
        }

        # Install the module SSL, Proxy, Proxy AJP
        class { 'apache::mod::ssl': }
        class { 'apache::mod::proxy': }

        if ($install_tomcat == true) {
            # Install Tomcat application server.
            include tomcat

            if ($configure_admin) {
              class { 'tomcat::admin':
                tomcat_admin_password   => $tomcat_admin_password,
                tomcat_manager_password => $tomcat_manager_password,
              }
            }

            apache::mod { 'proxy_ajp':  }

            apache::vhost { 'default-ssl-443':
              servername        => "${hostfqdn}:443",
              port              => '443',
              serveradmin       => $mailto,
              docroot           => $apache_doc_root,
              ssl               => true,
              ssl_cert          => "${shib2common::certificate::cert_directory}/cert-server.pem",
              ssl_key           => "${shib2common::certificate::cert_directory}/key-server.pem",
              ssl_chain         => "${shib2common::certificate::cert_directory}/Terena-chain.pem",
              ssl_protocol      => 'All -SSLv2 -SSLv3',
              ssl_cipher        => 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK',
              add_listen        => true,
              error_log         => true,
              error_log_file    => 'error.log',
              access_log        => true,
              access_log_file   => 'ssl_access.log',
              access_log_format => 'combined',
              custom_fragment   => '
      <Directory /usr/lib/cgi-bin>
         SSLOptions +StdEnvVars
      </Directory>

      #   SSL Protocol Adjustments:
      #   The safe and default but still SSL/TLS standard compliant shutdown
      #   approach is that mod_ssl sends the close notify alert but doesn\'t wait for
      #   the close notify alert from client. When you need a different shutdown
      #   approach you can use one of the following variables:
      #   o ssl-unclean-shutdown:
      #     This forces an unclean shutdown when the connection is closed, i.e. no
      #     SSL close notify alert is send or allowed to received.  This violates
      #     the SSL/TLS standard but is needed for some brain-dead browsers. Use
      #     this when you receive I/O errors because of the standard approach where
      #     mod_ssl sends the close notify alert.
      #   o ssl-accurate-shutdown:
      #     This forces an accurate shutdown when the connection is closed, i.e. a
      #     SSL close notify alert is send and mod_ssl waits for the close notify
      #     alert of the client. This is 100% SSL/TLS standard compliant, but in
      #     practice often causes hanging connections with brain-dead browsers. Use
      #     this only for browsers where you know that their SSL implementation
      #     works correctly.
      #   Notice: Most problems of broken clients are also related to the HTTP
      #   keep-alive facility, so you usually additionally want to disable
      #   keep-alive for those clients, too. Use variable "nokeepalive" for this.
      #   Similarly, one has to force some clients to use HTTP/1.0 to workaround
      #   their broken HTTP/1.1 implementation. Use variables "downgrade-1.0" and
      #   "force-response-1.0" for this.
      BrowserMatch "MSIE [2-6]" \
         nokeepalive ssl-unclean-shutdown \
         downgrade-1.0 force-response-1.0
      # MSIE 7 and newer should be able to use keepalive
      BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown
      ',
              require           => [Class['apache::mod::ssl', 'shib2common::certificate'], Apache::Mod['proxy_ajp']],
            }
        }
    }
}

