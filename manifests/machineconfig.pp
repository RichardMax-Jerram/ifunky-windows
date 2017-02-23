# == Class: machineconfig
#
# Module for managing machine.config settings (C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config).  It can create
# separate appSettings.config and connectionStrings.config files and source them in machine.config.
# The reason for doing this is to separate out sensitive application settings and db connection strings from an
# applications main config.
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
# [*dotnet_folder*]
#   .Net config folder where we can find machine.config
#
class windows::machineconfig (
  $manage_appsettings       = true,
  $manage_connectionstrings = true,
  $dotnet_folder            = 'C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\Config'
) {

  validate_absolute_path($dotnet_folder)

  $machine_config_fullpath    = "${dotnet_folder}\\machine.config"
  $appsettings_filename       = "appSettings.config"
  $appsettings_fullpath       = "${dotnet_folder}\\${appsettings_filename}"
  $connectionstrings_filename = "connectionStrings.config"
  $connectionstrings_fullpath = "${$dotnet_folder}\\${connectionstrings_filename}"

  if($manage_appsettings){
    file { $appsettings_fullpath:
      ensure  => 'file',
    }

    exec { 'Add app settings element with external source' :
      command   => "\$xmlFile = '${machine_config_fullpath}';[xml]\$xml = Get-Content \$xmlFile;\$newElement=\$xml.CreateElement(\"appSettings\");\$newElement.SetAttribute(\"configSource\", \"${appsettings_filename}\");\$xml.configuration.AppendChild(\$newElement);\$xml.Save(\$xmlFile)",
      onlyif    => "[xml]\$xml = Get-Content '${machine_config_fullpath}'; if (\$xml.configuration.appSettings -ne \$null) { exit 1 } else { exit 0 }",
      logoutput => true,
      provider => powershell,
    }

  }

  if($manage_connectionstrings){
    file { $connectionstrings_fullpath:
      ensure  => 'file',
    }

    exec { 'Remove machine.config default connection string xml element' :
      command   => "\$xmlFile = '${machine_config_fullpath}';[xml]\$xml = Get-Content \$xmlFile;[void]\$xml.configuration.RemoveChild(\$xml.configuration.connectionStrings);\$xml.Save(\$xmlFile)",
      onlyif    => "[xml]\$xml = Get-Content '${machine_config_fullpath}';if ( \$xml.configuration.SelectSingleNode(\"//connectionStrings/add[@name='LocalSqlServer']\") -ne \$null) { exit 0 } else { exit 1 }",
      logoutput => true,
      provider => powershell,
    }

    exec { 'Add connection string element with external source' :
      command   => "\$xmlFile = '${machine_config_fullpath}';[xml]\$xml = Get-Content \$xmlFile;\$newElement=\$xml.CreateElement(\"connectionStrings\");\$newElement.SetAttribute(\"configSource\", \"${connectionstrings_filename}\");\$xml.configuration.AppendChild(\$newElement);\$xml.Save(\$xmlFile)",
      onlyif    => "[xml]\$xml = Get-Content '${machine_config_fullpath}'; if (\$xml.configuration.connectionStrings -ne \$null) { exit 1 } else { exit 0 }",
      logoutput => true,
      provider => powershell,
    }
  }

}
