#
# randomstring.rb
#

module Puppet::Parser::Functions
  newfunction(:randomstring, :type => :rvalue, :doc => <<-EOS
    Returns a random string with a specified length.
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "randomstring(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1
      
    leng = arguments[0]

    # Numbers in Puppet are often string-encoded which is troublesome ...
    if leng.is_a?(String)
      if leng.match(/^-?(?:\d+)(?:\.\d+){1}$/)
        leng = leng.to_f
      elsif leng.match(/^-?\d+$/)
        leng = leng.to_i
      else
        raise(Puppet::ParseError, 'randomstring(): Requires an integer to work with')
      end
    end

    # We have numeric value to handle ...
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ0123456789'
  	randstring = ''
  	leng.times { randstring << chars[rand(chars.size)] }

    return randstring
  end
end

# vim: set ts=2 sw=2 et :
