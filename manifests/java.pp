# == Define: windows::java
#
# Module for installing the Java JDK and JRE.
# This module uses your own software repo rather than downloading from the web.
#
# === Parameters
#
# [*ensure*]
#   Can only be present or absent to install/remove
#
# [*version*]
#   Java major version to install
#
# === Examples
#
#   windows::java {'install java jdk':
#    arch => $::architecture,
#    type => 'jdk',
#  }
#
define windows::java (
  $ensure      = 'present',
  $destination = 'c:\\Program Files\\Java',
  $version     = '8',
  $update      = '121',
  $base_url    = 'https://s3-eu-west-1.amazonaws.com/puppet-stuff/AppSoftware/Java',
  $arch        = undef,
  $type        = 'jre',
) {

  include windows

  validate_absolute_path($destination)
  if (empty($version)){
    fail 'ERROR:: version was not specified'
  }
  if (empty($update)){
    fail 'ERROR:: update path was not specified'
  }

  validate_re($ensure,['^(present|absent)$'])
  validate_re($arch,['^(x86|x64)$'])
  validate_re($type,['^(jdk|jre)$'])

  case  $arch {
    'x64': {
      $java_arch = 'x64'
    }
    'x86': {
      $java_arch = 'i586'
    }
    default: {
      fail("Unknown architecture for JRE: $arch")
    }
  }

# Set Windows Package name and install folder location
  case  $type {
    'jre': {
      $java_env_name = 'JRE_HOME'
      if $java_arch == 'x64' {
        $java_package = "Java ${version} Update ${update} (64-bit)"
        $java_path = "$destination\\${$type}1.$version.0_$update"
      } else {
        $java_package = "Java ${version} Update ${update}"
        $java_path = "$destination (x86)\\Java\\${$type}1.$version.0_$update"
      }
    }
    'jdk': {
      $java_env_name = 'JAVA_HOME'
      if $java_arch == 'x64' {
        $java_package = "Java SE Development Kit ${version} Update ${update} (64-bit)"
        $java_path = "$destination\\${$type}1.$version.0_$update"
      } else {
        $java_package = "Java SE Development Kit ${version} Update ${update}"
        $java_path = "$destination (x86)\\Java\\${$type}1.$version.0_$update"
      }
    }
  }

  # Build package name
  $java_name = "$type-${version}u${update}-windows-${java_arch}.exe"
  $installer = "${$windows::temp_dir}\\$java_name"
  $package_url = "$base_url/$java_name"

  download_file { "Download Java $type" :
    url                   => $package_url,
    destination_directory => $windows::temp_dir,
    proxy_address         => $windows::proxy_server,
  }

  package { $java_package:
    ensure          => $ensure,
    source          => $installer,
    install_options => ['/s', "INSTALLDIR:$java_path"],
    require         => Download_file["Download Java $type"],
  }

  windows_env { "$java_env_name=$java_path" :
    ensure    => $ensure,
    mergemode => clobber,
    require   => Package[$java_package]
  }

  windows_env { "Update system path with $java_env_name" :
    ensure    => $ensure,
    mergemode => insert,
    variable  => 'path',
    value     => "%$java_env_name%",
    require   => Windows_env["$java_env_name=$java_path"]
  }

}
