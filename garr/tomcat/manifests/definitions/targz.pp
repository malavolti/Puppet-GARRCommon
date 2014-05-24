# == Definition: tomcat::targz
#
# Helper class that donwloads and extracts a tar.gz from the network.
#
# Parameters:
#
# - +source+: url of the tar.gz to be downloadaed.
# - +target+: target directory where to extract the downloaded tar.gz.
#
define tomcat::targz($source, $target) {
  package { "curl":
    ensure => installed,
  }
  
  exec {"$name unpack":
    command => "/usr/bin/curl ${source} | /bin/tar -xzf - -C ${target} && /bin/touch ${name}",
    creates => $name,
    require => Package["curl"],
  }
}