### centos
class apache::centos inherits apache::base {
  Package['apache'] {
    name => 'httpd',
  }
  Service['apache'] {
    name => 'httpd',
  }

  if $facts['os']['selinux']['enabled'] {
    selinux::fcontext {
      default:
        before => [Package['apache'],File['web_dir']];
      ['/var/www/vhosts/[^/]*/www(/.*)?',
        '/var/www/vhosts/[^/]*/tmp(/.*)?',
        '/var/www/vhosts/[^/]*/data(/.*)?',
      '/var/www/vhosts/[^/]*/upload(/.*)?']:
        setype => 'httpd_sys_rw_content_t';
      ['/var/www/vhosts/[^/]*/logs(/.*)?',
        '/var/log/fpm-.*(/.*)?',
      '/var/www/vhosts/[^/]*/www/log(/.*)?']:
        setype => 'httpd_log_t';
      '/var/www/vhosts/[^/]*/www/vendor/.*\.so[^/]*':
        setype => 'httpd_sys_script_exec_t';
      '/var/www/vhosts/[^/]*/virtualenv/.*\.so[^/]*':
        setype => 'httpd_sys_script_exec_t';
      '/var/www/vhosts/[^/]+/tmp/run(/.*)?':
        setype => 'httpd_var_run_t';
    }
  }
  Exec['reload_apache'] {
    command => 'systemctl reload httpd',
  }
  File['modules_dir'] {
    ensure => absent,
  }
  file_line {
    'mpm_prefork':
      path    => '/etc/httpd/conf.modules.d/00-mpm.conf',
      line    => 'LoadModule mpm_prefork_module modules/mod_mpm_prefork.so',
      match   => 'mpm_prefork_module',
      require => Package['apache'];
    'mpm_event':
      path    => '/etc/httpd/conf.modules.d/00-mpm.conf',
      line    => '#LoadModule mpm_event_module modules/mod_mpm_event.so',
      match   => 'mpm_event_module',
      require => Package['apache'];
  }

  exec {
    'adjust_listen':
      require => Package['apache'],
      notify  => Service['apache'];
  } -> apache::config::global { '00-listen.conf': }
  if $apache::http_listen {
    Exec['adjust_listen'] {
      command => 'sed -i  "s/^Listen 80/#Listen 80/g" /etc/httpd/conf/httpd.conf',
      onlyif  => 'grep -qE \'^Listen 80\' /etc/httpd/conf/httpd.conf',
    }
    Apache::Config::Global['00-listen.conf'] {
      content => template('apache/conf/listen.erb'),
    }
  } else {
    Exec['adjust_listen'] {
      command => 'sed -i  "s/^#Listen 80/Listen 80/g" /etc/httpd/conf/httpd.conf',
      unless  => 'grep -qE \'^Listen 80\' /etc/httpd/conf/httpd.conf',
    }
    Apache::Config::Global['00-listen.conf'] {
      ensure => absent,
    }
  }

  include apache::logrotate::centos

  apache::config::global { 'welcome.conf': }
  apache::config::global { 'vhosts.conf': }
}
