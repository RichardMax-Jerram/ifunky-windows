# == Class: windows::winsxs
#
# Downloads the winsxs source folders for installing features that aren't part of the base Windows installation.
#
# === Parameters
#
# [*winsxs_folder*]
#  Required, the target folder for the iso zip to be extracted
#
# [*winsxs_source_zip_url*]
#  Required, the source URL of the iso zip
#
class windows::winsxs(
  $winsxs_folder = hiera('windows::system::iso_folder'),
  $winsxs_source_zip_url  = hiera('windows::software::winsxs_source_zip_url')
) {

  include windows

  if (empty($winsxs_folder)){
    fail 'ERROR:: You must specify a target winsxs folder'
  }
  if (empty($winsxs_source_zip_url)){
    fail 'ERROR:: You must specify a source URL for the winsxs zip file'
  }

  $iso_source_zipfile_name =  get_filename_from_url($winsxs_source_zip_url)
  $iso_source_folder  = $winsxs_folder
  $iso_source_zipfile =  "$iso_source_folder\\$iso_source_zipfile_name"

  file { $iso_source_folder:
    ensure             => directory,
    path               => $iso_source_folder,
    source_permissions => ignore,
  }

  download_file { "ISO Source" :
    url                   => $winsxs_source_zip_url,
    destination_directory => $iso_source_folder,
    proxyAddress          => $windows::proxy_server,
    require               => File[$iso_source_folder],
    notify                => Windows::Unzip[$iso_source_zipfile],
  }

  windows::unzip { $iso_source_zipfile:
    destination => $iso_source_folder,
    creates     => "$iso_source_folder\\x86_wpf-winfxtargets_31bf3856ad364e35_6.3.9600.16384_none_5dd75921bd7cccb3\\microsoft.winfx.targets",
    require     => Download_file['ISO Source']
  }

}