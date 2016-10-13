# == Define: windows::web::createsite
#
# Module to help manage web configuration on Windows servers
#
# === Parameters
#
# [*site_name*]
#   Namee of the website that will be created in IIS.  Required.
#
# [*$root_web_folder*]
#   The root website that the site will be create in.  For example in Windows the default is c:\inetpub\wwroot
#
# === Examples
#
# class { 'windows::web::createsite':
#   site_name  => 'MyWebsite'
# }
#
define windows::web::createsite (
  $site_name        = '',
  $enable_32_bit    = false,
  $pipeline_mode    = 'Integrated',
  $runtime_version  = 'v4.0',
  $root_web_folder  = undef,
  $bindings         = undef,
) {

  include windows::web::config

# If root website folder was not passed in, use the default set in the config manifest
  if ($root_web_folder == '') or ($root_web_folder == undef) {
    $iis_root_web_folder = $windows::web::config::iis_root_folder
  } else {
    $iis_root_web_folder = $root_web_folder
  }

  validate_absolute_path($iis_root_web_folder)
  validate_array($bindings)

#notify { "****** ROOT:  $iis_root_web_folder": }
#$count = count($bindings)
#notify { "****** BINDINGS:  ${$bindings[0][host_header]}": }
#notify { "****** Create: $name 32: $32_bit":}

  $default_binding_port = $bindings[0][port]
  $default_binding_host_header = $bindings[0][host_header]
  $default_binding_ip_address = $bindings[0][ip_address]
  $default_binding_protocol = $bindings[0][protocol]

  if ! is_integer($default_binding_port) {
    fail 'Port can only be an integer value'
  }
  if $default_binding_ip_address != '*' {
    validate_ipv4_address($default_binding_ip_address)
  }

  iis::manage_app_pool {$site_name:
    enable_32_bit           => $enable_32_bit,
    managed_pipeline_mode   => $pipeline_mode,
    managed_runtime_version => $runtime_version,
    require => Windowsfeature['Web-WebServer'],
  }

  iis::manage_site_state {$site_name:
    site_name => $site_name,
    ensure  => running,
    require => Windowsfeature['Web-WebServer'],
  }

  iis::manage_site {$site_name:
    site_path     => "$iis_root_web_folder\\$site_name",
    port          => $default_binding_port,
    ip_address    => $default_binding_ip_address,
    host_header   => $default_binding_host_header,
    app_pool      => $site_name,
    require => Windowsfeature['Web-WebServer'],
  }

##  This needs to be a loop, REFACTOR ME! BINDING 2
  if $bindings[1] != undef {
    $second_binding_name = $site_name
    $second_binding_port = $bindings[1][port]
    $second_binding_host_header = $bindings[1][host_header]
    $second_binding_ip_address = $bindings[1][ip_address]
    $second_binding_protocol = $bindings[1][protocol]
    $second_binding_ssl_friendly_name = $bindings[1][ssl_friendly_name]
    $second_binding_ssl_thumbprint = $bindings[1][thumbprint]

    validate_re($second_binding_protocol,['^(http|https)$'], 'Protocol can only be \'http\' or \'https\'')

    if ! is_integer($second_binding_port) {
      fail 'Port can only be an integer value'
    }
    if $second_binding_ip_address != '*' {
      validate_ipv4_address($second_binding_ip_address)
    }

  # $second_binding_ssl_friendly_name
    #$ssl_thumbprint = clean_string(template("windows/get_ssl_thumbprint_by_friendlyname.erb"))

    notify { "+_+_+_+THUMBPRINT_$second_binding_protocol-$ssl_thumbprint":}

    iis::manage_binding { "${second_binding_host_header}-port-${second_binding_port}":
      site_name               => $site_name,
      protocol                => $second_binding_protocol,
      port                    => $second_binding_port,
      ip_address              => $second_binding_ip_address,
      host_header             => $second_binding_host_header,
      #certificate_thumbprint  => $ssl_thumbprint,
    }
  }

}