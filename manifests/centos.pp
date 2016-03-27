### centos
class apache::centos inherits apache::package {
  $config_dir = '/etc/httpd'

  Package['apache']{
    name => 'httpd',
  }
  Service['apache']{
    name    => 'httpd',
  }
  File['vhosts_dir']{
    path => "${config_dir}/vhosts.d",
  }
  File['config_dir']{
    path => "${config_dir}/conf.d",
  }
  File['include_dir']{
    path => "${config_dir}/include.d",
  }
  File['web_dir']{
    path => '/var/www/vhosts',
  }
  File['default_apache_index']{
    path => '/var/www/html/index.html',
  }

  if str2bool($::selinux) {
    Selinux::Fcontext{
      before => File['web_dir'],
    }
    $seltype_rw = $::operatingsystemmajrelease ? {
      5       => 'httpd_sys_script_rw_t',
      default => 'httpd_sys_rw_content_t'
    }
    selinux::fcontext{
      [ '/var/www/vhosts/[^/]*/www(/.*)?',
        '/var/www/vhosts/[^/]*/non_public(/.*)?',
        '/var/www/vhosts/[^/]*/data(/.*)?',
        '/var/www/vhosts/[^/]*/upload(/.*)?' ]:
        require => Package['apache'],
        setype  => $seltype_rw;
      '/var/www/vhosts/[^/]*/logs(/.*)?':
        require => Package['apache'],
        setype  => 'httpd_log_t';
    }
  }
  if versioncmp($::operatingsystemmajrelease,'6') > 0 {
    File['modules_dir']{
      ensure => absent,
    }
    file_line{
      'mpm_prefork':
        line  => 'LoadModule mpm_prefork_module modules/mod_mpm_prefork.so',
        match => 'mpm_prefork_module',
        path  => '/etc/httpd/conf.modules.d/00-mpm.conf';
      'mpm_event':
        line  => '#LoadModule mpm_event_module modules/mod_mpm_event.so',
        match => 'mpm_event_module',
        path  => '/etc/httpd/conf.modules.d/00-mpm.conf';
    }
  } else {
    File['modules_dir']{
      path => "${config_dir}/modules.d",
    }
    Service['apache']{
      restart => '/etc/init.d/httpd graceful',
    }
    file{'apache_service_config':
      path    => '/etc/sysconfig/httpd',
      source  => [  "puppet:///modules/site_apache/service/CentOS/${::fqdn}/httpd",
                    'puppet:///modules/site_apache/service/CentOS/httpd',
                    'puppet:///modules/apache/service/CentOS/httpd' ],
      require => Package['apache'],
      notify  => Service['apache'],
      owner   => root,
      group   => 0,
      mode    => '0644';
    }
  }

  # this is for later fixes
  if versioncmp($::operatingsystemmajrelease,'7') < 0 {
    exec{'adjust_pidfile':
      command => 'sed -i  "s/^#PidFile \(.*\)/PidFile \1/g" /etc/httpd/conf/httpd.conf',
      unless  => 'grep -qE \'^PidFile \' /etc/httpd/conf/httpd.conf',
      require => Package['apache'],
      notify  => Service['apache'];
    }
  }
  exec{
    'adjust_listen':
      command => 'sed -i  "s/^#Listen 80/Listen 80/g" /etc/httpd/conf/httpd.conf',
      unless  => 'grep -qE \'^Listen 80\' /etc/httpd/conf/httpd.conf',
      require => Package['apache'],
      notify  => Service['apache'];
  }

  apache::config::global{'00-listen.conf':
    ensure => absent,
  }

  include apache::logrotate::centos

  apache::config::global{ 'welcome.conf': }
  apache::config::global{ 'vhosts.conf': }
}

