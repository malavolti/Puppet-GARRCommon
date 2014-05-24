# == Definition: tomcat::admin
#
# Helper class to install Tomcat admin package.
#
# Parameters:
#
# +tomcat_admin_password+:: If the Tomcat administration interface is going to be installed this parameter permits to specify the password for the 'admin' user used by tomcat to access the administration interface. 
# +tomcat_manager_password+:: If the Tomcat administration interface is going to be installed this parameter permits to specify the password for the 'manager' user used by tomcat to access the administration interface.
#
class tomcat::admin(
  $tomcat_admin_password = 'adminpassword',
  $tomcat_manager_password = 'managerpassword',
) {
  
  $curtomcat = $::tomcat::curtomcat
  
  Class[$curtomcat] -> Class['tomcat::admin']
  
  package { "tomcat-admin":
    ensure => present,
    name   => "${curtomcat}-admin",
    require => Package[$curtomcat],
  }
  
  augeas { "tomcat_users_role_manager":
    context   => "/files/etc/${curtomcat}/tomcat-users.xml",
    changes   => [
      "set tomcat-users/role[last()+1] #empty",
      "set tomcat-users/role[last()]/#attribute/rolename manager",
    ],
    onlyif    => "match tomcat-users/role/#attribute/rolename[. = 'manager'] size == 0",
    require   => Package['tomcat-admin'],
  }
  
  augeas { "tomcat_users_role_administrator":
    context   => "/files/etc/${curtomcat}/tomcat-users.xml",
    changes   => [
      "set tomcat-users/role[last()+1] #empty",
      "set tomcat-users/role[last()]/#attribute/rolename administrator",
    ],
    onlyif    => "match tomcat-users/role/#attribute/rolename[. = 'administrator'] size == 0",
    require   => Package['tomcat-admin'],
  }

  augeas { "tomcat_users_user_admin":
    context   => "/files/etc/${curtomcat}/tomcat-users.xml",
    changes   => [
      "set tomcat-users/user[last()+1] #empty",
      "set tomcat-users/user[last()]/#attribute/username Admin",
      "set tomcat-users/user[last()]/#attribute/password $tomcat_admin_password",
      "set tomcat-users/user[last()]/#attribute/roles admin,manager",
    ],
    onlyif    => "match tomcat-users/user/#attribute/username[. = 'Admin'] size == 0",
    require   => Package['tomcat-admin'],
  }
  
  augeas { "tomcat_users_user_manager":
    context   => "/files/etc/${curtomcat}/tomcat-users.xml",
    changes   => [
      "set tomcat-users/user[last()+1] #empty",
      "set tomcat-users/user[last()]/#attribute/username Manager",
      "set tomcat-users/user[last()]/#attribute/password $tomcat_manager_password",
      "set tomcat-users/user[last()]/#attribute/roles manager",
    ],
    onlyif    => "match tomcat-users/user/#attribute/username[. = 'Manager'] size == 0",
    require   => Package['tomcat-admin'],
  }
  
}
