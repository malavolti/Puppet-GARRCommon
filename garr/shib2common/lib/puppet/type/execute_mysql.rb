# This Resource Type executes the SQL code, stored into 'sql' attribute, on the DB 'dbname' 
# for user 'user' with password 'password'.
# To verify if the SQL code is executable on the DB 'dbname' use the 'query_check_empty' attribute.
#
# Example:
#
# execute_mysql { 'uapprove-table-ToUAcceptance':
#		 user => 'uApprove',
#		 password => 'ldappassword',
#		 dbname => 'uApprove',
#		 query_check_empty => 'SHOW TABLES LIKE "ToUAcceptance"',
#		 sql => [join(['CREATE TABLE ToUAcceptance (',
#		               'userId VARCHAR(104) NOT NULL,',
#		               'version VARCHAR(104) NOT NULL,',
#		               'fingerprint VARCHAR(256) NOT NULL,',
#		               'acceptanceDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,',
#		               'PRIMARY KEY (userId, version)',
#		               ')'], ' ')],
#  }

module Puppet

	newtype(:execute_mysql) do
		@doc = "Executes SQL code on a mySQL database"

		newparam(:name, :namevar => true) do
			desc "The name of the resource"
		end

		newparam(:user) do
			desc "The user to connect to the database"
			defaultto ''
		end

		newparam(:password) do
			desc "The password to connect to the database"
			defaultto ''
		end
    
		newparam(:hostname) do
			desc "The database host name"
			defaultto "localhost"
		end
    
		newparam(:dbname) do
			desc "The database name"
		end
    
		newparam(:query_check_empty) do
			desc "The query that has to be executed to verify the sync status of the resource"
		end
    
		newparam(:sql) do
			desc "An array of SQL statements to be executed in on the DB"
		end
    
		validate do
			fail("hostname parameter is required") if self[:hostname].nil?
			fail("user parameter is required") if self[:user].nil?
			fail("password parameter is required") if self[:password].nil?
			fail("dbname parameter is required") if self[:dbname].nil?
			fail("query_check_empty parameter is required") if self[:query_check_empty].nil?
			fail("sql parameter is required with at least one element") if self[:sql].nil? or self[:sql].empty?
		end

		newproperty(:ensure) do
			desc "Whether the resource is in sync or not."

			defaultto :insync

			def retrieve
				require 'mysql' # Must be here to work, because the library 'mysql' doesn't exists before the line 54 of prerequisites.pp
				debug ("Executing query " + resource[:query_check_empty] + " to check if rule is updated.")
				# Exception Management
				begin
					# Establish the connection to the DB, resource[:dbname] 
					# on the host, resource[:hostname]
					# for user, resource[:user], with password [:password]
					# or raise a Puppet:Error exception
					con = Mysql.new(resource[:hostname], resource[:user], resource[:password], resource[:dbname]) or raise Puppet::Error, "Error while connecting to database."
					# Executes the query, resource[:query_check_empty] on the DB connected
					rs = con.query(resource[:query_check_empty])
					# Save the number of row found with con.query into 'elems' variable
					elems = rs.num_rows
					debug ("Query returned #{elems} rows.")
					rs.free # Invoke free to release the result set.
				# Capture the Mysql::Error exception if rise up and show the error state 
				rescue Mysql::Error => e
					debug ("Error code: #{e.errno}")
					debug ("Error message: #{e.error}")
					debug ("Error SQLSTATE: #{e.sqlstate}") if e.respond_to?("sqlstate")
					raise Puppet::Error, "Error while executing query #{rs}."
				# Finally ensure that the connection is closed. 
				ensure
					con.close
				end
         
				return (elems > 0) ? :insync : :outofsync
			end

			newvalue :outofsync
			newvalue :insync do
				# This 'require' must be here to work, 
				# because the library 'mysql' doesn't exists before the line 54 of prerequisites.pp
				require 'mysql'
				debug("Execute_mysql[name] = " + resource[:name] + ".")
				debug("Execute_mysql[user] = " + resource[:user] + ".")
				debug("Execute_mysql[password] = " + resource[:password] + ".")
				debug("Execute_mysql[hostname] = " + resource[:hostname] + ".")
				debug("Execute_mysql[dbname] = " + resource[:dbname] + ".")
				debug("Execute_mysql[query_check_empty] = " + resource[:query_check_empty] + ".")
				debug("Execute_mysql[sql] = " + resource[:sql].to_s + ".")
        
				begin 
					con = Mysql.new(resource[:hostname], resource[:user], resource[:password], resource[:dbname]) or raise Puppet::Error, "Error while connecting to database."
					# Execute each sql query into array 'resource[:sql]' on the DB Connected
					resource[:sql].each_line { |cursql| 
						debug("Executing query: #{cursql}")
        
						con.query(cursql) 
						debug "Query executed. Number of rows affected: #{con.affected_rows}"
					}
				rescue Mysql::Error => e
					debug "Error code: #{e.errno}"
					debug "Error message: #{e.error}"
					debug "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
					raise Puppet::Error, "Error while executing query #{cursql}."
				# Finally ensure that the connection is closed.
				ensure
					con.close
				end # begin
			end # :insync 
		end # ensure
	end # newtype
end # module

