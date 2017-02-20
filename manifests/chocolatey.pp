# == Class: windows::chocolatey
#
# Installs Chocolatey using a modified script that can go through a proxy server.
#
# === Parameters
#
# [*version*]
#  Version of chocolately to install.  Defaults to 0.9.9.11
#
# [*timeout*]
# Timeout for the chocolatey installation.  Defaults to 300 seconds (5 minutes)
#
class windows::chocolatey (
  $version = '0.10.3',
  $timeout = 300,
) {

  include windows

  $proxy_server = $windows::proxy_server
  $creates      = ['C:\Chocolatey','C:\ProgramData\chocolatey']

  if (! $creates and ! $refreshonly and ! $unless){
    fail("Must set one of creates, refreshonly, or unless parameters.\n")
  }

  if(empty($version)){
    fail("ERROR:: version was not specified")
  }

  windows_env {'chocolateyVersion':
    ensure    => present,
    value     => $version,
    mergemode => clobber,
  }

  exec { 'install chocolatey':
    command     => template('windows/chocolately_install.ps1.erb'),
    creates     => $creates,
    provider    => powershell,
    timeout     => $timeout,
    logoutput   => true,
    notify      => Exec['refresh env vars'],
    require     => [ Windows_env['chocolateyProxyLocation'], Windows_env['chocolateyVersion'] ]
  }

  exec { 'add proxy to choco':
    command     => "& choco config set proxy ${proxy_server}",
    provider    => powershell,
    timeout     => $timeout,
    logoutput   => true,
    refreshonly => true,
    require     => Exec['install chocolatey']
  }
}