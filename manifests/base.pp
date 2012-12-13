# setup base apache class
class apache::base {
  file{
    'vhosts_dir':
      ensure  => directory,
      path    => '/etc/apache2/vhosts.d',
      owner   => root,
      group   => 0,
      mode    => '0644';
    'config_dir':
      ensure  => directory,
      path    => '/etc/apache2/conf.d',
      owner   => root,
      group   => 0,
      mode    => '0644';
    'include_dir':
      ensure  => directory,
      path    => '/etc/apache2/include.d',
      owner   => root,
      group   => 0,
      mode    => '0644';
    'modules_dir':
      ensure  => directory,
      path    => '/etc/apache2/modules.d',
      owner   => root,
      group   => 0,
      mode    => '0644';
    'htpasswd_dir':
      ensure  => directory,
      path    => '/var/www/htpasswds',
      owner   => root,
      group   => 0,
      mode    => '0640';
    'web_dir':
      ensure  => directory,
      path    => '/var/www',
      owner   => root,
      group   => 0,
      mode    => '0644';
    'default_apache_index':
      path    => '/var/www/localhost/htdocs/index.html',
      content => template('apache/default/default_index.erb'),
      owner   => root,
      group   => 0,
      mode    => '0644';
  }
  anchor{'apache::basic_dirs::ready':
    require => File['vhosts_dir','config_dir','include_dir','modules_dir','htpasswd_dir','web_dir','default_apache_index']
  }

  service{'apache':
    ensure  => running,
    name    => 'apache2',
    enable  => true,
  }

  apache::config::include{ 'defaults.inc': }
  apache::config::global{ 'git.conf': }
  apache::vhost::file { '0-default': }
}
