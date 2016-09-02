# == Class: windows::web::config
#
# Module to configure a
#
# === Parameters
#
# [*site_def_name*]
#   The prefix for the website configs i.e. ICISNEWS_websites
#
# === Examples
#
#  windows::web::config {'test'}:
#    site_def_name => 'mywebsite',
#  }
#
class windows::web::config (
  $site_def_name    = '',
  $ssl_create_cert  = true,
  $ssl_subject      = 'ifunky.net',
  $ssl_name         = 'Local Certificate'
) {

  include windows

  if(empty($site_def_name)){
    fail "ERROR::site_def_name not specified"
  }

  $iis_root_folder = $windows::iis_web_folder

  $websites = hiera_hash("${site_def_name}_websites", {})
  validate_hash($websites)
  create_resources('windows::web::createsite', $websites)

  if ($ssl_create_cert) {
    windows::sslcert::create { 'Create cert':
      subject       => "CN=$ssl_subject",
      friendlyName  => "$ssl_name",
    }
  }

}