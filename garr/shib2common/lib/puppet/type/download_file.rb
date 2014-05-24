# Downloads a file from URL and puts it to a file on the system.
# If the destination file doesn't exist, it creates a new one.
#
# Example of declaration on the puppet manifests:
#
# 		download_file { "/usr/local/src/shibboleth-identityprovider-2.3.8":
#        url => "http://shibboleth.net/downloads/identity-provider/2.3.8/shibboleth-identityprovider-2.3.8-bin.zip",
#			extract => 'zip',
#			execute_command => [
#				"/usr/bin/find /usr/local/src/shibboleth-identityprovider-2.3.8 -type d -exec /bin/chmod 755 {} \\;",
#				"/usr/bin/find /usr/local/src/shibboleth-identityprovider-2.3.8 -type f -exec /bin/chmod 644 {} \\;",
#			],
#		}

# Include the Libraries for HTTP URI and for extracts URIs from a string
require 'open-uri'
require 'uri'

# Include methods into module Puppet
module Puppet

	newtype(:download_file) do
		@doc = "A new type of resource that downloads a file from an URL and put it on one on the system, existing or not."
    
		newparam(:name, :namevar => true) do
			desc "The name of the new file to be created"
		end

		newparam(:url) do
			desc "The file's URL to be downloaded"
      
			# Validation failed if the URL value doesn't match with an URI string
			validate do |value|
				fail("url parameter " + value + "' is not valid") unless value =~ URI::regexp
			end
		end
    
		newparam(:extract) do
			desc "A flag indicating whether the files should be extracted after download or not"
      
			validate do |value|
				acceptedvalues = ['zip', 'tar.gz']
				fail("Invalid value " + value + ". Accepted values are 'zip' and 'tar.gz'.") unless acceptedvalues.include?(value) 
			end # validate
		end
    
		newparam(:execute_command) do
			desc "An array of commands to be executed after download"
		end
    
		# Validation fails if the parameter 'url' doesn't provided when declare a new resource with this type
		validate do
			fail("url parameter is required") if self[:url].nil?
			fail("execute_command parameter is required to be undef or a valid array or string") unless self[:execute_command].nil? or self[:execute_command].kind_of?(Array) or self[:execute_command].kind_of?(String)
		end

		newproperty(:ensure) do
			desc "Whether the resource is in sync or not."

			defaultto :insync # Default value to say "its all ok and the resource is synchronized"

			# The question is: "are we sync?"
			# the answer Puppet found by comparing the current value provided by the method "retrieve" (defined here)
			# with the desired value set in the declaration on the manifests or with "defaultto". 
			# If the values match, then this resource doesn't need to be modified, and "Puppet" moves on another resource. 
			# Otherwise, the resource must be modified.
			#
			# +retrieve+:: Return the current value of the resource on the system.
			#
			# If the file with name 'name' exist ==> return insync
			# otherwise return outsync (ternary operator:  conditional ? if_true : if_false)
			def retrieve
				File.exists?(resource[:name]) ? :insync : :outofsync
			end
      
			# Define the outsync's value for the property 'ensure' to null
			newvalue :outofsync
      
			# Define the insync's value for the property 'ensure' to the desired state of his resource 
			newvalue :insync do
				# Debug messages displayed on the screen during the synchronization Puppet Agent <-> Puppet Master
				debug("Download_file[name] = " + resource[:name] + ".")
				debug("Download_file[url] = " + resource[:url] + ".")
				debug("Download_file[extract] = " + (resource[:extract].nil? ? "NULL" : resource[:extract]) + ".")
				if resource[:execute_command].nil?
					debug("Download_file[execute_command] = NULL.")
				else
					debug("Download_file[execute_command] = " + resource[:execute_command].join(', ') + ".") if resource[:execute_command].kind_of?(Array)
					debug("Download_file[execute_command] = " + resource[:execute_command] + ".") if resource[:execute_command].kind_of?(String)
				end #if
        
				if (resource[:extract])
					download_filename = "/tmp/"
					# Create a new, random, 8 character filename for 'resource[:url]' file that must be extracted.
					# With this trick we resolve eventually homonymy problems.
					8.times{
						download_filename << (65 + rand(25)).chr.to_s
					}
					download_filename = download_filename + File.extname(resource[:url])
				else
					download_filename = resource[:name]
				end # if
      
				# The desired state: The new file must be the same as the URL file.
				# 1) Open the destination file with File.open in binary write mode,
				# 2) Open the source file with open (open-uri class method) in binary read mode
				# 3) Write on the destination file the content of the source file byte per byte.
				File.open(download_filename, 'wb') do |saved_file|
					open(resource[:url], 'rb') do |read_file|
						saved_file.write(read_file.read)
					end
				end # File.open
        
				# If have to extract the file to the right position
				if resource[:extract]
					case resource[:extract]
						when 'zip'
							# WARNING: since zip does not have a flag similar to --string in tar, the final path of extraction
							# of the zip file is decided by the content of the zip itself.
							#
							# insert into "path" the directory where the file will be downloaded, 
							# extract into that directory the file downloaded before
							# finally, delete the downloaded file.
							path = Pathname.new(resource[:name] + "/../").cleanpath
							debug("Unzipping file " + download_filename + " to " + path.to_s + ".")
							system("/usr/bin/unzip " + download_filename + " -d " + path.to_s) or raise Puppet::Error, "Error while extracting donwloaded file."
							debug("Deleting file " + download_filename + ".")
							File.delete(download_filename)

						when 'tar.gz'
							path = Pathname.new(resource[:name]).cleanpath
							Dir.mkdir(path) unless File.exists?(path)
							debug("Untarring file " + download_filename + " to " + path.to_s + ".")
							system("/bin/tar xvzf " + download_filename + " -C " + path.to_s + " --strip=1") or raise Puppet::Error, "Error while extracting donwloaded file."
							debug("Deleting file " + download_filename + ".")
							File.delete(download_filename)
					end # case
				end #if
        
				# If commands are specified, execute them
				if resource[:execute_command]
					debug("Executing additional commands after download.")
					
					if resource[:execute_command].kind_of?(String)
						debug("Executing command " + resource[:execute_command] + ".")
						system(resource[:execute_command]) or raise Puppet::Error, "Error while executing commands after file download."
					else
						resource[:execute_command].each { |curcommand|
							debug("Executing command " + curcommand + ".")
							system(curcommand) or raise Puppet::Error, "Error while executing commands after file download."
						}
					end #if
				end # if
			end # newvalue :insync
		end # newproperty :ensure
	end # newtype
end # module Puppet
