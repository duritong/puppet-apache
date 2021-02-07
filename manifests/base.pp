# setup base apache class
class apache::base {
  package { 'apache':
    ensure => present,
  } -> file {
    'vhosts_dir':
      ensure  => directory,
      path    => $apache::vhosts_dir,
      purge   => true,
      recurse => true,
      force   => true,
      notify  => Service['apache'],
      owner   => root,
      group   => 0,
      mode    => '0640';
    'config_dir':
      ensure => directory,
      path   => $apache::confd_dir,
      owner  => root,
      group  => 0,
      mode   => '0640';
    'include_dir':
      ensure  => directory,
      path    => $apache::include_dir,
      purge   => true,
      recurse => true,
      force   => true,
      notify  => Service['apache'],
      owner   => root,
      group   => 0,
      mode    => '0640';
    'modules_dir':
      ensure  => directory,
      path    => $apache::modules_dir,
      purge   => true,
      recurse => true,
      force   => true,
      notify  => Service['apache'],
      owner   => root,
      group   => 0,
      mode    => '0640';
    'htpasswd_dir':
      ensure  => directory,
      path    => '/var/www/htpasswds',
      purge   => true,
      recurse => true,
      force   => true,
      notify  => Service['apache'],
      owner   => root,
      group   => 'apache',
      mode    => '0640';
    'web_dir':
      ensure => directory,
      path   => $apache::webdir,
      owner  => root,
      group  => 0,
      mode   => '0644';
    'default_apache_index':
      path    => $apache::default_apache_index,
      content => template('apache/default/default_index.erb'),
      owner   => root,
      group   => 0,
      mode    => '0644';
  } -> anchor { 'apache::basic_dirs::ready': }

  apache::config::include_file { 'defaults.inc': }
  apache::config::global { 'git.conf':
    content => template('apache/conf.d/git.conf.erb'),
  }
  if !$apache::no_default_site {
    apache::vhost::file { '0-default': }
  }

  service { 'apache':
    ensure => running,
    enable => true,
  } -> exec { 'reload_apache':
    refreshonly => true,
    command     => 'systemctl reload apache',
  }
}
