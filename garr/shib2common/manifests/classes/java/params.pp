# == Class: shib2idp::java::params
#
# This class contains params for installing java
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
class shib2common::java::params {
  $java_dir_name = 'java-7-oracle'
  $java_home     = "/usr/lib/jvm/${java_dir_name}"
}
