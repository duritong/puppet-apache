#
# apache module
#
# Copyright 2008, admin(at)immerda.ch
# Copyright 2008, Puzzle ITC GmbH
# Marcel Haerry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute
# it and/or modify it under the terms of the GNU
# General Public License version 3 as published by
# the Free Software Foundation.
#

# manage a simple apache
class apache (
  Optional[String] $cluster_node = undef,
  Boolean $use_firewall = false,
  Boolean $manage_munin = false,
  String $status_pwd = 'munin-access-change-me',
  Boolean $no_default_site = false,
  Optional[Variant[Array[Variant[String,Stdlib::Port]],Variant[String,Stdlib::Port]]] $http_listen = undef,
  Boolean $ssl = false,
  Optional[Variant[Array[Variant[String,Stdlib::Port]],Variant[String,Stdlib::Port]]] $https_listen = undef,
  Variant[Enum['absent'],Stdlib::Unixpath] $default_ssl_certificate_file = absent,
  Variant[Enum['absent'],Stdlib::Unixpath] $default_ssl_certificate_key_file   = absent,
  Variant[Enum['absent'],Stdlib::Unixpath] $default_ssl_certificate_chain_file = absent,
  Optional[String] $ssl_cipher_suite = undef,
) {
  if $ssl_cipher_suite {
    $real_ssl_cipher_suite = $ssl_cipher_suite
  } else {
    include certs::ssl_config
    $real_ssl_cipher_suite = $certs::ssl_config::ciphers_http
  }
  case $facts['os']['name'] {
    'CentOS': {
      $config_dir  = '/etc/httpd'
      $vhosts_dir  = "${apache::config_dir}/vhosts.d"
      $confd_dir   = "${apache::config_dir}/conf.d"
      $include_dir = "${apache::config_dir}/include.d"
      $modules_dir =  "${apache::config_dir}/modules.d"
      $webdir      = '/var/www/vhosts'
      $default_apache_index = '/var/www/html/index.html'
      include apache::centos
    }
    'Debian','Ubuntu': {
      $config_dir  = '/etc/apache2'
      $vhosts_dir  = "${apache::config_dir}/sites-enabled"
      $modules_dir = "${apache::config_dir}/mods-enabled"
      $confd_dir   = "${apache::config_dir}/conf.d"
      $include_dir = "${apache::config_dir}/include.d"
      $webdir      = '/var/www'
      $default_apache_index = '/var/www/index.html'

      include apache::debian
    }
    default: { fail("Operatingsystem ${facts['os']['name']} is not supported by this module") }
  }
  if $apache::manage_munin {
    class { 'apache::status':
      pwd => $status_pwd,
    }
  }
  if $apache::use_firewall { include firewall::rules::http }
  if $ssl { include apache::ssl }
}
