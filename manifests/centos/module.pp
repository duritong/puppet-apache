# deploy a module
define apache::centos::module (
  $ensure      = present,
  $source      = undef,
  $destination = undef
) {
  $modules_dir = "${apache::config_dir}/modules.d"
  $real_destination = $destination ? {
    ''      => "${modules_dir}/${name}.so",
    default => $destination,
  }
  $real_source = $source ? {
    ''  => [
      "puppet:///modules/site_apache/modules.d/${facts['networking']['fqdn']}/${name}.so",
      "puppet:///modules/site_apache/modules.d/${apache::cluster_node}/${name}.so",
      "puppet:///modules/site_apache/modules.d/${name}.so",
      "puppet:///modules/apache/modules.d/${facts['os']['name']}/${name}.so",
      "puppet:///modules/apache/modules.d/${name}.so",
    ],
    default => "puppet:///modules/${source}",
  }
  file { "modules_${name}.conf":
    ensure  => $ensure,
    path    => $real_destination,
    source  => $real_source,
    require => [File['modules_dir'], Package['apache']],
    notify  => Service['apache'],
    owner   => root,
    group   => 0,
    mode    => '0755';
  }
}
