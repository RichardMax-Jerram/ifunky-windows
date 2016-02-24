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
  $version = '0.9.9.11',
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

  if (!empty($proxy_server)){
    windows_env { 'chocolateyProxyLocation':
      ensure    => present,
      value     => $proxy_server,
      mergemode => clobber,
    }
  }

  windows_env {'chocolateyVersion':
    ensure    => present,
    value     => $base::chocolateyVersion,
    mergemode => clobber,
  }

  exec { 'install chocolatey':
    command     => template('windows/chocolately_install.ps1.erb'),
    creates     => $creates,
    refreshonly => $refreshonly,
    unless      => $unless,
    provider    => powershell,
    timeout     => $timeout,
    logoutput   => true,
    require     => [ Windows_env['chocolateyProxyLocation'], Windows_env['chocolateyVersion'] ]
  }
}