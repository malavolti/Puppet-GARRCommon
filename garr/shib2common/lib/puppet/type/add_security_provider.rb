# This Puppet Resource Type adds the security providers into the right position on a java.security file 
#
# Example:
#  
#  add_security_provider { 'security-providers':
#    javasecurity_file => "/usr/lib/jvm/${shib2idp::java::params::java_dir_name}/jre/lib/security/java.security",
#    providerclasses => ['edu.internet2.middleware.shibboleth.DelegateToApplicationProvider', 'edu.internet2.middleware.shibboleth.quickInstallIdp.AnyCertProvider'],
#  }

module Puppet

	newtype(:add_security_provider) do
		@doc = "Add the security providers into the right position in a java.security file"

		newparam(:name, :namevar => true) do
			desc "The name of the resource."
		end

		newparam(:javasecurity_file) do
			desc "The java.security file to modify."
		end

		newparam(:providerclasses) do
			desc "The provider classes to adds."
		end
    
		validate do
			fail("javasecurity_file parameter is required") if self[:javasecurity_file].nil?
			fail("providerclasses parameter is required with at least one class") if self[:providerclasses].nil? or self[:providerclasses].empty? 
		end

		newproperty(:ensure) do
			desc "Whether the resource is insync or not."

			defaultto :insync

			def retrieve
				updated = false
        
				resource[:providerclasses].each do |curprovider|
					debug("Checking file " + resource[:javasecurity_file] + " for security provider with class " + curprovider + ".")
			
					File.readlines(resource[:javasecurity_file]).map do |curline|
						updated = true if (curline =~ /security.provider.[0-9]+=#{curprovider}/)
					end
       			end
        
				if (updated)
					debug("Does not have to update java.security.")
					:insync # Resource is already at the desired state
				else
					debug("Has to update java.security.")
					:outofsync # Resource isn't at the desired state, so I must following the ':insync' block to synchronize it
				end
			end

			newvalue :outofsync
      
			newvalue :insync do
				debug("Add_security_provider[name] = " + resource[:name] + ".")
				debug("Add_security_provider[javasecurity_file] = " + resource[:javasecurity_file] + ".")
				debug("Add_security_provider[providerclasses] = " + resource[:providerclasses].join(", ") + ".")
        
				secProv_num = 0
				secProv_lastLineno = 0
				fileLineno = 0
				newfilelines = []
				File.readlines(resource[:javasecurity_file]).map do |curline|
					if (curline =~ /security.provider.[0-9]+=.+/)
						secProv_num = secProv_num + 1
						secProv_lastLineno = fileLineno	 
					end
					newfilelines << curline
					fileLineno = fileLineno + 1
				end # File.readlines

				# This block insert the correct security provider into the right position
				resource[:providerclasses].map do |curprovider|
					secProv_lastLineno = secProv_lastLineno + 1
					newfilelines.insert(secProv_lastLineno, "security.provider." + secProv_num.to_s + "=" + curprovider + "\n")
					secProv_num = secProv_num + 1
				end
		
				debug("Writing destination file " + resource[:javasecurity_file] + ".")
				File.open(resource[:javasecurity_file], "wb") do |saved_file|
					newfilelines.map do |curline|
						saved_file.write(curline)
					end
				end # File.open
			end # newvalue :insync
		end # newproperty[:ensure]
	end # newtype
end # module Puppet