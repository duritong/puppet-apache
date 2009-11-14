class apache::base {
    file{'vhosts_dir':
        path => '/etc/apache2/vhosts.d',
        ensure => directory,
        owner => root, group => 0, mode => 0755;
    }
    file{'config_dir':
        path => '/etc/apache2/conf.d',
        ensure => directory,
        owner => root, group => 0, mode => 0755;
    }
    file{'modules_dir':
        path => '/etc/apache2/modules.d',
        ensure => directory,
        owner => root, group => 0, mode => 0755;
    }
    file{'htpasswd_dir':
        path => '/var/www/htpasswds',
        ensure => directory,
        owner => root, group => apache, mode => 0640;
    }
    file{'web_dir':
        path => '/var/www',
        ensure => directory,
        owner => root, group => 0, mode => 0755;
    }
    service { apache:
        name => 'apache2',
        enable => true,
        ensure => running,
    }
    file { 'default_apache_index':
        path => '/var/www/localhost/htdocs/index.html',
        ensure => file,
        content => template('apache/default/default_index.erb'),
        owner => root, group => 0, mode => 0644;
    }

    apache::config::file{ 'defaults.inc': }
    apache::config::file{ 'git.conf': }
    apache::vhost::file { '0-default': }
}
