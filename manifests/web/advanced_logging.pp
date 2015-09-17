# == Class: windows::web::advanced_logging
#
# Installs the Microsoft IIS Advanced Logging framework
#
# === Parameters
#
# [*log-path*]
#   Custom log file location i.e. c:\iislogs
#
# === Examples
#
#  windows::web::advanced_logging {'test'}:
#    log_path => 'c:\\iislogs',
#  }
#
class windows::web::advanced_logging (
  $log_path = '',
  $installer_msi_url = 'https://s3-eu-west-1.amazonaws.com/puppet-stuff/AppSoftware/Microsoft/Advancedlogging/AdvancedLogging64.msi'
) {

  include windows

  validate_absolute_path($log_path)
  if (empty($installer_msi_url)){
    fail 'ERROR:: installer_msi_url was not specified'
  }

  $installer_target_path  = $windows::temp_dir
  $installer_msi_name     = get_filename_from_url($installer_msi_url)
  $installer_source_path  = "$installer_target_path\\$installer_msi_name"

  download_file { 'Install Microsoft IIS Advanced Logging' :
    url                   => $installer_msi_url,
    destination_directory => $installer_target_path,
    proxyAddress          => $windows::proxy_server,
  }

  package { 'Microsoft IIS Advanced Logging':
    ensure          => $ensure,
    source          => $installer,
    install_options => ['/q', '/norestart'],
    require         => Download_file['Install Microsoft IIS Advanced Logging'],
  }

  file { 'iis_advanced_logs_path':
    ensure             => directory,
    path               => $log_path,
    source_permissions => ignore
  }

}