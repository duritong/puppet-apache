# deploy apache configuration file
# by default we assume it's a global configuration file
define apache::config::file (
  $ensure      = present,
  $target      = false,
  $type        = 'global',
  $source      = 'absent',
  $content     = 'absent',
  $destination = 'absent'
) {
  case $type {
    'include': { $confdir = 'include.d' }
    'global': { $confdir = 'conf.d' }
    default: { fail("Wrong config file type specified for ${name}") }
  }
  include apache
  $real_destination = $destination ? {
    'absent' => "${apache::config_dir}/${confdir}/${name}",
    default  => $destination,
  }
  file { "apache_${name}":
    ensure  => $ensure,
    path    => $real_destination,
    require => Package['apache'],
    notify  => Service['apache'],
    owner   => root,
    group   => 0,
    seltype => $apache::config_seltype,
    mode    => '0640';
  }

  case $ensure {
    'absent', 'purged': {
      # We want to avoid all stuff related to source and content
    }
    'link': {
      if $target {
        File["apache_${name}"] {
          target => $target,
        }
      }
    }
    default: {
      case $content {
        'absent': {
          $real_source = $source ? {
            'absent' => [
              "puppet:///modules/site_apache/${confdir}/${facts['networking']['fqdn']}/${name}",
              "puppet:///modules/site_apache/${confdir}/${apache::cluster_node}/${name}",
              "puppet:///modules/site_apache/${confdir}/${facts['os']['name']}.${facts['os']['release']['major']}/${name}",
              "puppet:///modules/site_apache/${confdir}/${facts['os']['name']}/${name}",
              "puppet:///modules/site_apache/${confdir}/${name}",
              "puppet:///modules/apache/${confdir}/${facts['os']['name']}.${facts['os']['release']['major']}/${name}",
              "puppet:///modules/apache/${confdir}/${facts['os']['name']}/${name}",
              "puppet:///modules/apache/${confdir}/${name}",
            ],
            default => $source
          }
          File["apache_${name}"] {
            source => $real_source,
          }
        }
        default: {
          case $content {
            'absent': {
              $real_source = $source ? {
                'absent' => [
                  "puppet:///modules/site-apache/${confdir}/${facts['networking']['fqdn']}/${name}",
                  "puppet:///modules/site-apache/${confdir}/${apache::cluster_node}/${name}",
                  "puppet:///modules/site-apache/${confdir}/${facts['os']['name']}.${facts['os']['release']['major']}/${name}",
                  "puppet:///modules/site-apache/${confdir}/${facts['os']['name']}/${name}",
                  "puppet:///modules/site-apache/${confdir}/${name}",
                  "puppet:///modules/apache/${confdir}/${facts['os']['name']}.${facts['os']['release']['major']}/${name}",
                  "puppet:///modules/apache/${confdir}/${facts['os']['name']}/${name}",
                  "puppet:///modules/apache/${confdir}/${name}",
                ],
                default => $source,
              }
              File["apache_${name}"] {
                source => $real_source,
              }
            }
            default: {
              File["apache_${name}"] {
                content => $content,
              }
            }
          }
        }
      }
    }
  }
}
