# == Class: proxysettings
#
# Module for managing proxy server settings that appear in the following locations:
# ** Environment Variables:  Typically http_proxy, https_proxy & no_proxy
# ** Machine.Config:         Sets the system default proxy in machine.config only and removes any settings in web.config
#
# === Parameters
#
# Document parameters here.
#
# [*manage_appsettings*]
#   If the appSettings section should be managed by this module.  Defaults to true.
#
# [*manage_connectionstrings*]
#   If the connectionStrings section should be managed by this module.  Defaults to true.
#
# [*proxy_server*]
#   Proxy server address i.e. http://my-proxy-server.com:3128
#
class windows::proxysettings (
  $manage_env_vars       = true,
  $manage_machine_config = true,
  $proxy_server          = undef,
  $proxy_exclusions      = undef,
  $dotnet_folder            = 'C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\Config'
) {

  if(!empty($proxy_server)){
    validate_re($proxy_server, ['^(http(?:s)?\:\/\/[a-zA-Z0-9]+(?:(?:\.|\-)[a-zA-Z0-9]+)+(?:\:\d+)?(?:\/[\w\-]+)*(?:\/?|\/\w+\.[a-zA-Z]{2,4}(?:\?[\w]+\=[\w\-]+)?)?(?:\&[\w]+\=[\w\-]+)*)$'], "ERROR: You must enter a proxy url in a valid format i.e. http://proxy.net:3128")
  }

  if ($manage_env_vars) {
    if (!empty($proxy_server)){
      windows_env { 'http_proxy':
        ensure    => present,
        variable  => 'http_proxy',
        value     => $proxy_server,
        mergemode => clobber,
      }

      windows_env { 'https_proxy':
        ensure    => present,
        variable  => 'https_proxy',
        value     => $proxy_server,
        mergemode => clobber,
      }
    }
    if (!empty($proxy_exclusions)){
      windows_env { 'no_proxy':
        ensure    => present,
        value     => $proxy_exclusions,
        mergemode => clobber,
      }
    }

  }

  $web_config_fullpath    = "${dotnet_folder}\\web.config"
  $machine_config_fullpath    = "${dotnet_folder}\\machine.config"

  if ($manage_machine_config) {
    exec { 'Remove web.config default proxy settings' :
      command   => "\$xmlFile = '${web_config_fullpath}';[xml]\$xml = Get-Content \$xmlFile;[void]\$xml.configuration.\"system.net\".RemoveChild(\$xml.configuration.\"system.net\".defaultProxy);\$xml.Save(\$xmlFile)",
      onlyif    => "[xml]\$xml = Get-Content '${web_config_fullpath}'; if (\$xml.configuration.\"system.net\" -ne \$null) { exit 1 } else { exit 0 }",
      logoutput => true,
      provider => powershell,
    }

    exec { 'Add system.net section to machine.config' :
      command   => "\$xmlFile = '${machine_config_fullpath}';[xml]\$xml = Get-Content \$xmlFile;\$newElement=\$xml.CreateElement('system.net');[void]\$xml.configuration.AppendChild(\$newElement);\$xml.Save(\$xmlFile)",
      onlyif    => "[xml]\$xml = Get-Content '${machine_config_fullpath}'; if (\$xml.configuration.\"system.net\" -ne \$null) { exit 1 } else { exit 0 }",
      logoutput => true,
      provider => powershell,
    }

    exec { 'Add default proxy element' :
      command   => "\$xmlFile = '${machine_config_fullpath}';[xml]\$xml = Get-Content \$xmlFile;\$newElement=\$xml.CreateElement('defaultProxy');\$node=\$xml.SelectNodes('/configuration/system.net').AppendChild(\$newElement) | Out-Null;\$xml.Save(\$xmlFile)",
      onlyif    => "[xml]\$xml = Get-Content '${machine_config_fullpath}'; if (\$xml.configuration.\"system.net\".defaultProxy -ne \$null) { exit 1 } else { exit 0 }",
      logoutput => true,
      provider => powershell,
    }

  }

}
