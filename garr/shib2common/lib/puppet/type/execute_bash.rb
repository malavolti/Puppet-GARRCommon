# Open, or creates a new one, the file '/tmp/path_into_parameter_name' into write mode
# and writes the content of the ':command' parameter on it.
# Then executes the entire bash script with the '/bin/bash' command calling the system call 'system'
# Finally deletes the new file created.
#
#   Example:
#   execute_bash { 'certs_installkeystore':
#     cwd => $cert_directory,
#     command => template("shib2idp/import_keystore.erb"),
#   }
#
# Parameters:
#   namevar or title       ==>  :name    ==> 'certs_installkeystore'                  (REQUIRED)
#   Current Work Directory ==>  :cwd     ==> $cert_directory == "/root/certificates"  (REQUIRED)
#   Command to use         ==>  :command ==> template("shib2idp/import_keystore.erb") (REQUIRED)

module Puppet

	newtype(:execute_bash) do
		@doc = "Execute a bash script only when notified"

		newparam(:name, :namevar => true) do
			desc "The name of the action"
		end

		newparam(:cwd) do
			desc "The current working directory for the script to be executed"
			defaultto "/root"
		end

		newparam(:command) do
			desc "The command to be executed"
		end
    
		# Validation fails if the parameters "url" and "command" are missing.
		validate do
			fail("command parameter is required") if self[:command].nil?
			fail("sources_file cwd is required") if self[:cwd].nil?
		end
    
####	'ensure' property is not necessary, because it is not used.
#		newproperty(:ensure) do
#			desc "Whether the resource is in sync or not."
#
#			defaultto :insync
#
#			def retrieve
#				# Returns always notrun to permit re-installations if something was changed or updated in the source folder.
#				:insync
#			end
#
#			newvalue :outofsync
#			newvalue :insync do
#				# Do nothing only execute install when refreshed
#			end
####	end
    
		# Define method 'refresh' to respond to a refresh events for this resource
     
		def refresh
			# Debug messages displayed on the screen during the synchronization Puppet Agent <-> Puppet Master
			debug("Shibboleth_install[name] = " + @parameters[:name].value + ".")
			debug("Shibboleth_install[cwd] = " + @parameters[:cwd].value + ".")
			debug("Shibboleth_install[command] = " + @parameters[:command].value + ".")
      
			# Open, or creates a new one, the file '/tmp/path_into_parameter_name' into write mode
			# and writes the content of the ':command' parameter on it.
			# Then executes the entire bash script with the '/bin/bash' command calling the system call 'system'
			# Finally deletes the new file created. 
			filename = "/tmp/" + @parameters[:name].value + ".sh"
			File.open(filename, "w") do |saved_file|
				saved_file.write(@parameters[:command].value)
			end
      
			debug("Executing the bash script.")
			system("/bin/bash " + filename)       # This System Call execute the "/bin/bash" command on the file 'filename'
        
			debug("Deleting file " + filename + ".")
			File.delete(filename)                 # This instruction delete the file 'filename'
		end
	end
end
