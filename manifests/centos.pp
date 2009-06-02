### centos
class apache::centos inherits apache::package {
    $config_dir = '/etc/httpd/'

    Package[apache]{
        name => 'httpd',
    }
    Service[apache]{
        name => 'httpd',
        restart => '/etc/init.d/httpd graceful',
    }
    File[vhosts_dir]{
        path => "$config_dir/vhosts.d/",
    }
    File[config_dir]{
        path => "$config_dir/conf.d/",
    }
    File[modules_dir]{
        path => "$config_dir/modules.d/",
    }
    File[web_dir]{
        path => "/var/www/vhosts",
    }
    File[default_apache_index]{
        path => '/var/www/html/index.html',
    }

    file{'/etc/sysconfig/httpd':
      source => [ "puppet://$server/files/apache/sysconfig/${fqdn}/httpd",
                  "puppet://$server/files/apache/sysconfig/httpd",
                  "puppet://$server/apache/sysconfig/${operatingsystem}/httpd",
                  "puppet://$server/apache/sysconfig/httpd" ],
      require => Package['apache'],
      notify => Service['apache'],
      owner => root, group => 0, mode => 0644;
    }

    # add vhost folders to logrotation
    augeas { "logrotate_httpd_vhosts":
      changes => [ 'rm /files/etc/logrotate.d/httpd/rule/file',
        'ins file before /files/etc/logrotate.d/httpd/rule/*[1]',
        'ins file before /files/etc/logrotate.d/httpd/rule/*[1]',
        'set /files/etc/logrotate.d/httpd/rule/file[1] /var/log/httpd/*log',
        'set /files/etc/logrotate.d/httpd/rule/file[2] /var/www/vhosts/*/logs/*log' ],
    }

    apache::config::file{ 'welcome.conf': }
    apache::config::file{ 'vhosts.conf': }
}

