import "classes/*.pp"
import "definitions/*.pp"

# == Class: tomcat
#
#This module is provided to you by GARR after a modification of the original
#module from Camptocamp[http://camptocamp.com/].
#
#This module will install tomcat, either from a compressed archive or using
#your system's package manager. This is done by including one of these classes:
#- tomcat::package::v6
#- tomcat::v6
#
#=== Instances:
#
# You'll then be able to define one or more tomcat instances, where you can drop
# your webapps in the ".war" format. This is done with the "tomcat::instance"
# definition.
#
# The idea is to have several independent tomcats running on the same host, each
# of which can be restarted and managed independently. If one of them happens to
# crash, it won't affect the other instances. The drawback is that each tomcat
# instance starts it's own JVM, which consumes memory.
#
# This is implemented by having a shared $CATALINA_HOME, and each instance having
# it's own $CATALINA_BASE. More details are found in this document:
# [http://tomcat.apache.org/tomcat-6.0-doc/RUNNING.txt]
#
#=== Logging:
#
#To offer more flexibility and avoid having to restart tomcat each time
#catalina.out is rotated, tomcat is configured to send it's log messages to
#log4j. By default log4j is configured to send all log messages from all
#instances to /var/log/tomcat/tomcat.log.
#
#This can easily be overridden on an instance base by creating a custom
#log4j.properties file and setting the "common.loader" path to point to it, by
#editing /srv/tomcat/<name>/conf/catalina.properties.
#
# Parameters:
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# The Apache puppet module available at
# [http://github.com/camptocamp/puppet-apache] is required if you want to make
# use of Apache integration.
#
# The Common puppet module available at
# [http://github.com/camptocamp/puppet-common] is required if you want to install
# tomcat from a compressed archive (it uses common::archive::tar-gz).
#
# Sample Usage:
# To you this class you can follow the rules here described.
#
# By default a new tomcat instance create by a tomcat::instance resource will
# listen on the following ports:
#
# * 8080 HTTP
# * 8005 Control
# * 8009 AJP
#
# You should override these defaults by setting attributes server_port,
# http_port and ajp_port.
#
# === Examples
#
# == Simple standalone instance
#
# Create a standalone tomcat instance whose HTTP server listen on port 8080:
#
#   include tomcat::v6
#
#   tomcat::instance {"myapp":
#     ensure    => present,
#     http_port => "8080",
#   }
#
# == Apache integration:
#
# Pre-requisites:
#
#   include apache
#
#   apache::module {"proxy_ajp":
#     ensure  => present,
#   }
#
#   apache::vhost {"www.mycompany.com":
#     ensure => present,
#   }
#
# Create a tomcat instance which is accessible via Apache using AJP on a given
# virtualhost:
#
#   include tomcat::v6
#
#   tomcat::instance {"myapp":
#     ensure      => present,
#     ajp_port    => "8000",
#     http_port   => "",
#   }
#
#   apache::proxypass {"myapp":
#     ensure   => present,
#     location => "/myapp",
#     vhost    => "www.mycompany.com",
#     url      => "ajp://localhost:8000",
#   }
#
#
# == Multiple instances
#
# If you create multiple Tomcat instances, you must avoid port clash by setting
# distinct ports for each instance::
#
#   include tomcat::package::v6
#
#   tomcat::instance {"tomcat1":
#     ensure      => present,
#     server_port => "8005",
#     http_port   => "8080",
#     ajp_port    => "8009",
#   }
#
#   tomcat::instance {"tomcat2":
#     ensure      => present,
#     server_port => "8006",
#     http_port   => "8081",
#     ajp_port    => "8010",
#   }
#
class tomcat {
  if($lsbdistid == 'Debian'){
    include tomcat::tomcat6
    $tomcat_home = $tomcat6::tomcat_home
    $catalina_out = $tomcat6::catalina_out
    $catalina_home = $tomcat6::catalina_home
    
    $curtomcat = "tomcat6"

  }elsif($lsbdistid == 'Ubuntu'){
    include tomcat::tomcat7
    $tomcat_home = $tomcat7::tomcat_home
    $catalina_out = $tomcat7::catalina_out
    $catalina_home = $tomcat7::catalina_home
    
    $curtomcat = "tomcat7"
  }
  else{
    include tomcat::tomcat6
    $tomcat_home = $tomcat6::tomcat_home
    $catalina_out = $tomcat6::catalina_out
    $catalina_home = $tomcat6::catalina_home
    
    $curtomcat = "tomcat6"
  }
}
