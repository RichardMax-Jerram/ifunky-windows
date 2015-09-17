# Returns a Windows environment variable by name
#
# Example:
# get_windows_env_byname('windir')
#
module Puppet::Parser::Functions
  newfunction(:get_windows_env_byname, :type => :rvalue) do |args|

    environment_variable_name = args[0]
    return ENV[environment_variable_name]
  end
end
