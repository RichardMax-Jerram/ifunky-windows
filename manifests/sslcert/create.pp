# == Define: windows::sslcert::create
#
# Creates SSL certificates on a target host.
#
# === Parameters
#
# [*site_def_name*]
#   The prefix for the website configs i.e. ICISNEWS_websites
#
# === Examples
#
#  class { 'windows::web::config':
#    site_def_name => 'mywebsite',
#  }
#
define windows::sslcert::create (
  $subject      = '',
  $friendlyName = '',
) {

  include windows

  if(empty($subject)){
    fail "ERROR:: subject not specified for ssl cert"
  }
  if(empty($friendlyName)){
    fail "ERROR:: friendlyName not specified for ssl cert"
  }

  file { "New-SelfSignedCertificateEx.ps1":
    ensure  => present,
    path    => "C:\windows\\temp\\New-SelfSignedCertificateEx.ps1",
    content => file('windows/New-SelfSignedCertificateEx.ps1'),
  }

  exec { "CreateSSLCert-${friendlyName}":
    command   => template("windows/create_sslcert.erb"),
    onlyif    => "if ( (Get-ChildItem -Path Cert:\\LocalMachine\\My | Where-Object {\$_.FriendlyName -match \"$friendlyName\"}).Thumbprint -ne \$null) { exit 1 } else { exit 0 }",
    require   => File["New-SelfSignedCertificateEx.ps1"],
    provider  => powershell,
    logoutput => true,
  }


}