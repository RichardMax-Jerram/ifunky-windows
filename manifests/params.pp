# Author::    Dan Gibbons
# Copyright:: Copyright (c) 2015 RBI
# License::   MIT
#
# == Class windows::params
#
# Default parameters for the Windows admin module.
#
class windows::params {
  $proxy_server    = ''
  $iis_web_folder  = 'c:\inetpub\wwwroot'
  $temp_dir        = get_windows_env_byname('TEMP')
}