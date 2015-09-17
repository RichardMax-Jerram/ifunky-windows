# == Define: windows::gem
#
# Install or remove gems in Windows.
# This is to work around the limitation of the Puppet package resource installing gems in it's own
# ruby installation and not the global onje used by the OS
#
# === Parameters
#
# [*name*]
#  Required, gem name to install
#
# [*version*]
#  Optiona;, version of gem to install
#
# [*ensure*]
#  Required, set to installed or absent
#
define windows::gem(
  $gem_name             = $title,
  $version              = '',
  $ruby_install_folder  = 'c:\tools\ruby21',
  $ensure,
) {

  include windows

  if (empty($gem_name)){
    fail 'ERROR:: You must specify a gem name to install'
  }
  if (!empty($version)){
    validate_re($version, ['^(\d+\.)?(\d+\.)?(\*|\d+)$'], "ERROR: version must be in the format 1.1.22")
  }
  validate_absolute_path($ruby_install_folder)
  validate_re($ensure,['^(installed|absent)$'], "ERROR: ensure must be installed or absent")

  if (!empty($version)) {
    $version_string = "-v $version"
  } else {
    $version_string = ''
  }

  $gem_bat_file = "$ruby_install_folder\\bin\\gem.bat"

  case $ensure {
    'installed': { $gem_command = "$gem_bat_file install $gem_name $version_string" }
    'absent':    { $gem_command = "$gem_bat_file uninstall $gem_name $version_string" }
    default:     { }
  }

  exec { "install gem $gem_name":
    command   => $gem_command,
    onlyif    => "\$gemName = '${gem_name}';\$version = '${version}';if (\$version) { \$version = \"{0}{1}{2}\" -f '\\(', \$version.Replace('.','\\.'), '\\)'};\$gemVersion = \"\$gemName \$version\";if (${gem_bat_file} list | select-string \$gemVersion | % { \$_.Matches } | % { \$_.Value }) { exit 1 } else { exit 0 }",
    provider  => powershell,
    logoutput => true,
  }

}