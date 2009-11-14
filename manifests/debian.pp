### debian
class apache::debian inherits apache::package {
    $config_dir = '/etc/apache2'

    file {"$vhosts_dir":
        ensure => "${config_dir}/sites-enabled",
    }
    File[default_apache_index] {
        path => '/var/www/index.html',
    }
}

