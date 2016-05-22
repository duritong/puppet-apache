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
class apache(
  $cluster_node                       = '',
  $manage_shorewall                   = false,
  $manage_munin                       = false,
  $no_default_site                    = false,
  $ssl                                = false,
  $default_ssl_certificate_file       = absent,
  $default_ssl_certificate_key_file   = absent,
  $default_ssl_certificate_chain_file = absent,
  $ssl_cipher_suite                   = $certs::ssl_config::ciphers_http
) {
  case $::operatingsystem {
    'CentOS': {
      $config_dir = '/etc/httpd'
      include apache::centos
    }
    'Gentoo': {
      $config_dir = '/etc/apache2'
      include apache::gentoo
    }
    'Debian','Ubuntu': {
      $config_dir = '/etc/apache2'
      include apache::debian
    }
    'OpenBSD': {
      $config_dir = '/var/www'
      include apache::openbsd
    }
    default: { fail("Operatingsystem ${::operatingsystem} is not supported by this module") }
  }
  if $apache::manage_munin {
    include apache::status
  }
  if $apache::manage_shorewall {
    include shorewall::rules::http
  }
  if $ssl {
    include apache::ssl
  }
}

