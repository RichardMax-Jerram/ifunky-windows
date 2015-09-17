[![Build Status](https://travis-ci.org/ifunky/ifunky-windows.svg?branch=master)](https://travis-ci.org/ifunky/ifunky-windows)

ifunky-windows
=======

The Windows module provides a selection of helpers for common administrative tasks.


Windows Classes
---------------
### `windows::winsxs`

Extracts winsxs zip file to a target folder.

```windows:winsxs
windows::winsxs { 'ISO Source':
  winsxs_folder         => 'C:\iso_source',
  winsxs_source_zip_url => 'http:://software/iso_source.zip',
}
```
**Parameters within `windows_winsxs`:**
#####`winsxs_folder`
  * Local folder to extract zip file, folder will be created if it doesn't exist
#####`winsxs_source_zip_url `
  * URL to zip file containing the target OS WinSxS source folders

Windows Defined Types
---------------------

### `windows::unzip`

Uses the native Windows unzip functionality for unzipping files.

```windows:unzip
windows::unzip { 'C:\zipfile.zip':
  destination => 'C:\temp',
  creates     => 'C:\temp\fromzipfile.txt',
}
```
### `windows::java`

Installs the Java JDK or Java JRE.  This module downloads the installers from a custom HTTP location which you need to populate with beforehand.

> Example using the defaults to install the Java JDK V8.45.

      class { windows::java:
        arch => $::architecture,
        type => 'jdk',
      }

**Parameters within `windows_java`:**
#####`ensure`
  * present - Ensure package is installed
  * absent - Ensure package is removed
#####`version`
  * Numeric major Java version number i.e. 8
 #####`update`
  * Numeric update Java version number i.e. 45
#####`base_url`
  * String location of the root folder containing your Java installers i.e. http://yoursharedserver/software/java
#####`arch`
  * String - System architecture type x86|x64.   Or use a fact $::architecture
#####`type`
  * String - Install JDK or JRE.  Accepted values jre|jdk

### `windows::web::config`

Resource that manages the configuration and creation of websites.
NOTE: If you want to use hash merging functionality across the hierarchy you'll need to set deeper merge on.

**Parameters within `windows::web::config`:**
#####`site_def_name`
  * Because hash merging can be used you may not want to merge everything so site_def_name is used to identify different hashes

> Example
Given you have some Hiera data to describe one or many websites:

    ---
    [SITE_DEF_NAME]_websites:
      mywebsite:
         site_name: Website1
         enable_32_bit: false
         pipeline_mode: Integrated
         runtime_version: v4.0
         bindings:
          -
            port: 80
            host_header:
            ip_address: *
            protocol: http

You can call create to kick off the creation:

      class { 'windows::web::config':
        site_def_name  => '[SITE_DEF_NAME]'
      }

### `windows::web::createsite`

Resource that creates a website based on some standards, this can be used to create one or many websites managed by Hiera data.

 - The application pool will always have the same name as the website
 - One or many bindings can be set at create time

**Parameters within `windows::web::createsite`:**
#####`site_name`
  * Name of the IIS site to create (required)
#####`enable_32_bit`
  * true | false - if the applicaiton pool should be 32bit. Defaults to false
#####`pipeline_mode`
  * Integrated | Classic - IIS pipeline mode.  Defaults to Integrated
#####`runtime_version`
  * v4.0 | v2.0 - Dotnet runtime version.  Defaults to v4.0
#####`root_web_folder`
  * Root folder of IIS i.e. c:\inetpub\wwwroot.  New websites will be created inside this parent folder
#####`bindings`
  * Array of hashes representing bindings:
  bindings:
          -
            port: 80
            host_header:
            ip_address: *
            protocol: http
