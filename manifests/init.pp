# == Class: windows
#
# Module for administering common Windows activites.
#
# === Parameters
#
# Document parameters here.
#
# [*temp_dir*]
#   Defaults to the current users TEMP folder i.e. %USERPROFILE%\AppData\Local\Temp
#
# [*proxy_server*]
#   Optional, proxy server to use to download files i.e. http://proxyserver.net:3128
#
# [*$iis_web_folder*]
#   Optional, IIS root folder to use for new websites, defaults to c:\inetpub\wwwroot
#
class windows (
  $temp_dir       = $windows::params::temp_dir,
  $proxy_server   = $windows::params::proxy_server,
  $iis_web_folder = $windows::params::iis_web_folder
) inherits windows::params {

  if $::osfamily != 'windows' {
    fail("You can only run this module in Windows (/2008/2012+)\n")
  }

  #validate_absolute_path($iis_web_folder, "ERROR: iis_web_folder must be a valid path")
  #validate_absolute_path($temp_dir, "ERROR: temp_dir must be a valid path")

  if(!empty($proxy_server)) {
    unless $proxy_server =~ /^(http(?:s)?\:\/\/[a-zA-Z0-9]+(?:(?:\.|\-)[a-zA-Z0-9]+)+(?:\:\d+)?(?:\/[\w\-]+)*(?:\/?|\/\w+\.[a-zA-Z]{2,4}(?:\?[\w]+\=[\w\-]+)?)?(?:\&[\w]+\=[\w\-]+)*)$/ {
      fail ('you must enter a proxy url in a valid format i.e. http://proxy.net:3128')
    }
  }

}
