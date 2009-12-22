### debian
class apache::debian inherits apache::package {
    $config_dir = '/etc/apache2'

    Package[apache] {
	    name => 'apache2',
    }
    File[vhosts_dir] {
        path => "${config_dir}/sites-enabled",
    }
    File[modules_dir] {
        path => "${config_dir}/mods-enabled",
    }
    File[htpasswd_dir] {
        path => "/var/www/htpasswds",
	group => 'www-data',
    }
    File[default_apache_index] {
        path => '/var/www/index.html',
    }
    file { 'default_debian_apache_vhost':
        path => '/etc/apache2/sites-enabled/000-default',
        ensure => absent,
    }
}

