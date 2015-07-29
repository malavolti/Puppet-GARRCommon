# This Puppet Resource Type adds an user into LDAP on DN 'rootdn' with an LDIF File.
# 'ldif_search' permit to verify if the user to add is already exists
#
# Example:
#  
#  execute_ldap { 'ldapadd-test-user':
#    rootdn => "cn=admin,dc=example,dc=com",
#    rootpw => ldappassword,
#    ldif_search => "uid=test,ou=people,dc=example,dc=com",
#    ldif => template("shib2idp/testuser.ldif.erb"),
#    require => [Package['libldap-ruby1.8'], File_line['eduperson-schema', 'schac-schema']],
#  }

module Puppet

	newtype(:execute_ldap) do
		@doc = "Executes ldapadd to add a ldif file"

		newparam(:name, :namevar => true) do
			desc "The name of the resource"
		end

		newparam(:rootdn) do
			desc "The DN to connect to the database"
		end

		newparam(:rootpw) do
			desc "The password to connect to the database"
		end
    
		newparam(:hostname) do
			desc "The database host name"
			defaultto "localhost"
		end
    
		newparam(:ldif_search) do
			desc "The base to be passed to ldapsearch to verify the sync status of the resource"
		end
    
		newparam(:ldif) do
			desc "The LDIF string to be sent to the ldapadd command"
		end
    
		validate do
			fail("rootdn parameter is required") if self[:rootdn].nil?
			fail("rootpw parameter is required") if self[:rootpw].nil?
			fail("hostname parameter is required") if self[:hostname].nil?
			fail("ldif_search parameter is required") if self[:ldif_search].nil?
			fail("ldif parameter is required") if self[:ldif].nil?
		end

		newproperty(:ensure) do
			desc "Whether the resource is in sync or not."

			defaultto :insync

			def retrieve
				# This 'require' must be here to work, 
				# because the library 'ldap' doesn't exists before the line 46 of prerequisites.pp
				require 'ldap'
				    
				debug ("Searching element " + resource[:ldif_search] + " to check if rule is updated.")
				# Connect to an LDAP with LDAP:Conn.new($hostname,$port)
				conn = LDAP::Conn.new(resource[:hostname], LDAP::LDAP_PORT) or raise Puppet::Error, "Error while connecting to LDAP database."
				# Set the protocol of this connection to LDAPv3
				conn.set_option( LDAP::LDAP_OPT_PROTOCOL_VERSION, 3 ) or raise Puppet::Error, "Error while connecting to LDAP database."
				# Bind an LDAP connection using the DN, resource[:rootdn], 
				# the credential, resource[:rootpw] 
				# and the default bind method LDAP::LDAP_AUTH_SIMPLE
				conn.bind(resource[:rootdn], resource[:rootpw]) or raise Puppet::Error, "Error while connecting to LDAP database."
        
				# Exception Management
				begin
					elems = 0
					# Perform a search, with the base DN 'resource[:ldif_search], 
					# the scope LDAP::LDAP_SCOPE_BASE (Search only the base node)
					# the search filter '(objectclass=*)
					# the attributes that the search should return ( ['*'] == All Attributes)
					#
					# Each time that the research has success, elems will be incremented by one. 
					conn.search(resource[:ldif_search], LDAP::LDAP_SCOPE_BASE, '(objectclass=*)', ['*']) {
						elems += 1
					}
					# If the search fails an LDAP::ResultError exception will rise up
					# and the 'elems' variable will be set to 0
					# The LDAP::ResultError will be saved into 'err' variable
				rescue LDAP::ResultError => err
					elems = 0
				# In case of an error, the new, bind or unbind methods raise an LDAP::Error exception
				# The LDAP::Error will be saved into 'msg' variable
				rescue LDAP::Error => msg
					# If an LDAP::Error exception rises up, Puppet show that exception message into its exception error 
					raise(Puppet::Error, "Error while executing LDAP search for " + resource[:ldif_search] + ": " + msg)
				end
				# Finally unbind the LDAP connection
				conn.unbind
        
				debug ("LDAP search returned #{elems} elements.")
				# If the search has found at least an element (elems > 0) 
				# the resource is synchronized ':insync', otherwise must be synchronized ':outofsync'
				return (elems > 0) ? :insync : :outofsync
			end # retrieve

			newvalue :outofsync
			newvalue :insync do
				# This 'require' must be here to work,
				# because the library 'ldap' doesn't exists before the line 46 of prerequisites.pp
				require 'ldap'       
				require 'ldap/ldif'
      
				debug("Execute_mysql[name] = " + resource[:name] + ".")
				debug("Execute_mysql[rootdn] = " + resource[:rootdn] + ".")
				debug("Execute_mysql[rootpw] = " + resource[:rootpw] + ".")
				debug("Execute_mysql[hostname] = " + resource[:hostname] + ".")
				debug("Execute_mysql[ldif_search] = " + resource[:ldif_search] + ".")
				debug("Execute_mysql[ldif] = " + resource[:ldif] + ".")
        
				conn = LDAP::Conn.new(resource[:hostname], LDAP::LDAP_PORT) or raise Puppet::Error, "Error while connecting to LDAP database."
				conn.set_option( LDAP::LDAP_OPT_PROTOCOL_VERSION, 3 ) or raise Puppet::Error, "Error while connecting to LDAP database."
				conn.bind(resource[:rootdn], resource[:rootpw]) or raise Puppet::Error, "Error while connecting to LDAP database."
        
				begin
					# Parse the LDIF entry 'resource[:ldif] and return an LDAP::Record object into 'elems'.
					elems = LDAP::LDIF.parse_entry(resource[:ldif].split("\n"))
					#  Send the operation embodied in the Record object 'elems' to the LDAP::Conn object specified in conn. 
					elems.send(conn)
					debug ("LDIF " + resource[:ldif] + " inserted in LDAP.")
				rescue LDAP::Error => msg
					raise(Puppet::Error, "Error while executing LDIF in LDAP " + resource[:ldif] + ": " + msg)
				end # begin
				conn.unbind # Finally unbind the LDAP connection
			end # insync
		end # ensure
	end # newtype
end # module Puppet

