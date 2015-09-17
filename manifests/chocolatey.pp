# == Define: windows::unzip
#
# Installs chocolatey
#
# === Parameters
#
# [*destination*]
#  Required, the destination directory to extract the files into.
#
# [*creates*]
#  The `creates` parameter for the exec resource that extracts the ZIP file,
#  default is undefined.
#
# [*timeout*]
# Execution timeout in seconds for the unzip command; 0 disables timeout,
# defaults to 300 seconds (5 minutes).
#
class windows::chocolatey(
  $creates = ['C:\Chocolatey','C:\ProgramData\chocolatey'],
  $timeout = 300,
) {

  include windows

  $proxy_server = $windows::proxy_server

  if (! $creates and ! $refreshonly and ! $unless){
    fail("Must set one of creates, refreshonly, or unless parameters.\n")
  }

  exec { 'install chocolatey':
    command     => template('windows/chocolately_install.ps1.erb'),
    creates     => $creates,
    refreshonly => $refreshonly,
    unless      => $unless,
    provider    => powershell,
    timeout     => $timeout,
    logoutput   => true,
  }
}