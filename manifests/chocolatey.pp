# == Class: windows::chocolatey
#
# Installs Chocolatey using a modified script that can go through a proxy server.
#
# === Parameters
#
# [*version*]
#  Version of chocolately to install.  Defaults to 0.10.3
#
# [*download_url*]
#  Default download URL for the Chocolatey package
#
# [*destination_path *]
#  Destination path where to install Chocolatey
#
class windows::chocolatey (
  $version          = '0.10.5',
  $download_url     = 'https://chocolatey.org/api/v2/package/chocolatey',
  $destination_path = 'c:\ProgramData\chocolatey',
) {

  include windows

  $temp_folder              = $::windows::temp_dir
  $proxy_server             = $::windows::proxy_server
  $choco_download_url       = "${download_url}/${version}"
  $destination_for_download = 'c:\windows\temp\choco'

  if(empty($version)){
    fail("ERROR:: version was not specified")
  }

  file { $destination_for_download:
    ensure             => directory,
  }

  windows_env { 'ChocolateyInstall':
    ensure    => present,
    value     => $destination_path,
    mergemode => clobber,
  }

  download_file { 'Download Chocolaty' :
    url                    => "${download_url}/${version}",
    destination_directory  => $destination_for_download,
    proxy_address          => $proxy_server,
    require                => Windows_env['ChocolateyInstall']
  }

  windows::unzip { 'Unzip choco':
    zipfile     => "$destination_for_download\\${version}",
    destination => $destination_for_download,
    creates     => "${destination_for_download}\\tools\\chocolateyInstall.ps1",
    require     => Download_file['Download Chocolaty']
  }

  exec { 'Install chocolatey':
    command     => "& c:\\windows\\temp\\choco\\tools\\chocolateyInstall.ps1",
    creates     => "$destination_path\\choco.exe",
    provider    => powershell,
    logoutput   => true,
    notify      => Exec['Add proxy to choco'],
    require     => [ Windows::Unzip['Unzip choco'] ]
  }

  exec { 'Add proxy to choco':
    command     => "& C:\\ProgramData\\chocolatey\\choco.exe config set proxy ${proxy_server}",
    onlyif      => "if ([string]::IsNullOrEmpty('${proxy_server}') )  { exit 1 } else { exit 0 }",
    provider    => powershell,
    logoutput   => true,
    refreshonly => true,
    require     => Exec['Install chocolatey']
  }
}