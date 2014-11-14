# == Class: shib2common::augeas
#
# This class ensure the presence of Augeas on Puppet agent machine.
# Augeas is used to manipulate configuration files and to perform all the relevant configuration
# operations requested to have the Shibboleth IdP properly configured and running.
#
# Information about Augeas can be found at this link:
# {http://augeas.net/}[http://augeas.net/].
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
class shib2common::augeas (
  $augeas_version = undef,
  $augeas_ruby_version = undef,
) {

  $lens_dir        = '/usr/share/augeas/lenses'

  $version         = $augeas_version ? {
    ''      => 'present',
    undef   => 'present',
    default => $augeas_version
  }

  $rubylib_version = $augeas_ruby_version ? {
    ''      => 'present',
    undef   => 'present',
    default => $augeas_ruby_version,
  }

  if($lsbdistid == 'Ubuntu'){
    if ($rubyversion == '1.8.7'){
      package { ['augeas-lenses','libaugeas0','augeas-tools','libaugeas-ruby1.8']:
         ensure => 'present',
      }
    }
    # For Ruby 1.9.3
    else{
       package { 'libaugeas-ruby1.8':
         ensure => 'purged',
       }

       package { ['augeas-lenses','libaugeas0','augeas-tools','ruby-augeas']:
         ensure => 'present',
      }
    }
  }
  elsif($lsbdistid == 'Debian' and $lsbdistcodename == 'squeeze'){
    apt_repository { 'backports_repository':
      repository_type    => ['deb'],
      repository_url     => 'http://backports.debian.org/debian-backports',
      repository_targets => ['squeeze-backports', 'main'],
    } 

    file { '/etc/apt/preferences.d/augeas':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => join(["Package: augeas-lenses",
                       "Pin: release a=squeeze-backports",
                       "Pin-Priority: 999",
                       "",
                       "Package: libaugeas0",
                       "Pin: release a=squeeze-backports",
                       "Pin-Priority: 999",
                       "",
                      "Package: augeas-tools",
                       "Pin: release a=squeeze-backports",
                       "Pin-Priority: 999",
                       "",
                       "Package: libaugeas-ruby1.8",
                       "Pin: release a=squeeze-backports",
                       "Pin-Priority: 999"], "\n"),
    }

    package {
      ['augeas-lenses','libaugeas0','augeas-tools']:
        ensure  => $version,
        require => Apt_repository['backports_repository'];

      'libaugeas-ruby1.8':
        ensure  => $rubylib_version,
        require => Apt_repository['backports_repository'];
      }
  }
  # All other supported systems: Debian Wheezy
  else{
    package { ['augeas-lenses','libaugeas0','augeas-tools','libaugeas-ruby1.9.1']:
      ensure => 'present',
    }
  }

  # ensure no file not managed by puppet ends up in there.
  file {
    "${lens_dir}":
      ensure       => directory,
      purge        => true,
      force        => true,
      recurse      => true,
      recurselimit => 1,
      mode         => '0644',
      owner        => 'root',
      group        => 'root',
      require      => Package['augeas-lenses'];

    "${lens_dir}/dist":
      ensure  => directory,
      purge   => false,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Package['augeas-lenses'];

    "${lens_dir}/tests":
      ensure  => directory,
      purge   => true,
      force   => true,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => Package['augeas-lenses'];
  }

  if ($augeasversion == '0.10.0'){
   file { 
    '/usr/share/augeas/lenses/dist/tomcatxml.aug':
      ensure => present,
      owner  => root,
      group  => root,
      mode   => '644',
      source => 'puppet:///modules/shib2common/customlenses/tomcatxml_0-10-0.aug',
      require => File["${lens_dir}/dist"];

    '/usr/share/augeas/lenses/dist/webappxml.aug':
      ensure => present,
      owner  => root,
      group  => root,
      mode   => '644',
      source => 'puppet:///modules/shib2common/customlenses/webappxml_0-10-0.aug',
      require => File["${lens_dir}/dist"];
   }
  }
  if ($augeasversion == '1.2.0'){
   file { 
    '/usr/share/augeas/lenses/dist/tomcatxml.aug':
      ensure => present,
      owner  => root,
      group  => root,
      mode   => '644',
      source => 'puppet:///modules/shib2common/customlenses/tomcatxml_1-2-0.aug',
      require => File["${lens_dir}/dist"];

    '/usr/share/augeas/lenses/dist/webappxml.aug':
      ensure => present,
      owner  => root,
      group  => root,
      mode   => '644',
      source => 'puppet:///modules/shib2common/customlenses/webappxml_1-2-0.aug',
      require => File["${lens_dir}/dist"];
   }
  }


}
