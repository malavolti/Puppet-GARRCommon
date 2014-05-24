# This Puppet Resource type add an apt repository, 
# eventually permit to download and trust the public key. 
# In the end performs an 'apt-get update'
#
# Example:
#
#  apt_repository { 'java_repository':
#    repository_type => ['deb', 'deb-src'],
#    repository_url => 'http://ppa.launchpad.net/webupd8team/java/ubuntu',
#    repository_targets => ['precise', 'main'],
#    sources_file => 'java.list',
#    key_name => 'EEA14886',
#    key_file => 'puppet:///modules/shib2idp/C2518248EEA14886.key',
#  }

#require 'puppet/resource/catalog'
#require 'puppet/indirector/code'

module Puppet

	newtype(:apt_repository) do
		@doc = "Add an apt repository and eventually download and trust the public key"

		newparam(:name, :namevar => true) do
			desc "The name of the resource"
		end

		newparam(:repository_type) do
			desc "The type of repository to be added. Possible values are: 'deb', 'deb-src'. Default value is 'deb'."
      
			defaultto ['deb']
      
			validate do |value|
				acceptedvalues = ['deb', 'deb-src']

        if (value.class==String)
          value = value.split # Must have for Ruby >= 1.9
        end
      
				value.map do |curval|
					fail("Invalid value " + curval + ". Accepted values are 'deb' and 'deb-src'.") unless acceptedvalues.include?(curval) 
				end # map
			end # validate
		end # newparam [:repository_type]

		newparam(:repository_url) do
			desc "The URL of the repository"
      
			# Fails if the repository URL isn't in a correct URL format.
			validate do |value|
				fail ("Invalid source #{value}") unless URI.parse(value).is_a?(URI::HTTP)
			end
		end
    
		newparam(:repository_targets) do
			desc "The targets of the repository. Default value is 'main'"
      
			defaultto ["main"]
		end
    
		newparam(:sources_file) do
			desc "The file where the repository should be added in APT sources. Default value is 'sources.list'"
			defaultto "sources.list"
		end
    
		newparam(:key_name) do
			desc "The name of the public key to be trusted for the repository."
		end
    
		newparam(:key_file) do
			desc "The public key to be trusted for the repository."
		end
    
		validate do
			fail("'repository_type' parameter is required with at least one element") if self[:repository_type].nil? or self[:repository_type].empty?
			fail("'repository_url' parameter is required") if self[:repository_url].nil?
			fail("'repository_targets' parameter is required with at least one element") if self[:repository_targets].nil? or self[:repository_targets].empty?
			fail("'sources_file' parameter is required") if self[:sources_file].nil?
			fail("'key_file' parameter is required when key_name specified") if !self[:key_name].nil? and self[:key_file].nil?
			fail("'key_name' parameter is required when key_file specified") if !self[:key_file].nil? and self[:key_name].nil?
		end

		newproperty(:ensure) do
			desc "Whether the resource is in sync or not."

			defaultto :insync

			def retrieve
				path = resource[:sources_file].eql?("sources.list") ? "/etc/apt/" : "/etc/apt/sources.list.d/"
      	
				fileline = []
				# Insert into the 'fileline' array this lines:
				# deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main
				# deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main
				#
				# deb                                                curtype
				# ' '                                                space
				# http://ppa.launchpad.net/webupd8team/java/ubuntu   resource[:repository_url]
				# ' '                                                space
				# precise main                                       resource[:repository_targets].join(' ') 
        if (resource[:repository_type].class == String)
          resource[:repository_type] = resource[:repository_type].split # Must have for Ruby >= 1.9
        end
 
				resource[:repository_type].map { |curtype|
					fileline << curtype + " " + resource[:repository_url] + " " + resource[:repository_targets].join(" ") + "\n"
				}
        
				updated = false
        
				# If the file /path/resource[:source_file] exist remove from it the characters '/n'
				if (File.exist?(path + resource[:sources_file]))
					fileline.map do |curline|
						debug("Checking file " + path + resource[:sources_file] + " for line " + curline + ".")
            
						filecontent = File.readlines(path + resource[:sources_file])
						updated = true if filecontent.include?(curline)
					end # fileline.map
				end # if
        
				if (updated)
					debug("Does not have to update APT.")
					:insync
				else
					debug("Has to update APT.")
					:outofsync
				end
			end

			newvalue :outofsync

			newvalue :insync do
 				debug("Updating APT.")
				path = resource[:sources_file].eql?("sources.list") ? "/etc/apt/" : "/etc/apt/sources.list.d/"
        
				fileline = []
        
        if (resource[:repository_type].class == String)
          resource[:repository_type] = resource[:repository_type].split # Must have for Ruby >= 1.9
        end
  
				resource[:repository_type].map do |curtype|
					fileline << curtype + " " + resource[:repository_url] + " " + resource[:repository_targets].join(' ') + "\n"
				end
        
				fileline.map do |curline|
					debug("Appending line " + curline + " to file  " + path + resource[:sources_file] + ".")
					addline = true

					if (File.exist?(path + resource[:sources_file]))
						fileline.map do |curline|
							debug("Checking file " + path + resource[:sources_file] + " for line " + curline + ".")
              
							filecontent = File.readlines(path + resource[:sources_file])
							added = false if filecontent.include?(curline)  
						end # fileline  
					end # if
          
					if (addline == true)
						debug("Adding line " + curline)
						File.open(path + resource[:sources_file], 'a') do |aptfile|
							aptfile.write(curline)
						end
					else
						debug("Not adding line " + curline)
					end # if 
				end # fileline.map
        
				# If the variable 'resource[:key_file]' has a value different from 'nil' or '' (empty string) 
				# search the right file on Puppet Master, insert his content into 'filecontent' variable 
				# and write it on a file, named resource[:name].key, into /tmp directory.
				# After that, call /usr/bin/apt-key to add the key stored into /tmp/resource[:name] 
				# if it doesn't already exists.
				# Finally delete the temporary key from /tmp directory and call an 'apt-get update'
          
				if (defined?(resource[:key_file]) && resource[:key_file] != nil && resource[:key_file] != '')
					debug("Adding keyfile to APT.")
					filecontent = Puppet::FileServing::Content.indirection.find(resource[:key_file]).content
        	  
					File.open("/tmp/" + resource[:name] + ".key", "wb") do |saved_file|          
						saved_file.write(filecontent)
					end
					# the ‘backquotes‘ execute a bash command and returns its values
					system ("/usr/bin/apt-key add /tmp/" + resource[:name] + ".key") unless (`/usr/bin/apt-key list`.include?(resource[:key_name]))
          
					File.delete("/tmp/" + resource[:name] + ".key")
				end
        
				debug("Executing apt-get update")
				system ("/usr/bin/apt-get update")
			end
		end
	end
end

