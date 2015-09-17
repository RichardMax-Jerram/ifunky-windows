require 'open3'

module Puppet::Parser::Functions
  newfunction(:get_sslcert_thumbprint_by_friendlyname, :type => :rvalue) do |args|

    ssl_friendly_name = args[0]
    script = <<-EOF
      (Get-ChildItem -Path Cert:\\LocalMachine\\My | Where-Object {$_.FriendlyName -match '#{ssl_friendly_name}'}).Thumbprint
    EOF
    cmd = "powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command \"#{script}\""

    stdout,stderr,status = Open3.capture3(cmd)
    #puts stdout

    return stdout
  end
end
