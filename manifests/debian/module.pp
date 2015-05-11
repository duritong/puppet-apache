# install/remove apache module on debian/ubuntu systems
define apache::debian::module(
    $ensure = present,
    $package_name = 'absent'
){
    $modules_dir = "${apache::debian::config_dir}/mods"

    if ($package_name != 'absent') {
        package { $package_name:
            ensure  => $ensure,
            notify  => Service['apache'],
            require => Package['apache'],
        }
    }

    case $ensure {
        'absent','purged': {
            exec { "/usr/sbin/a2dismod ${name}":
                onlyif  => "/bin/sh -c '[ -L ${modules_dir}-enabled/${name}.load ] \\
                    && [ ${modules_dir}-enabled/${name}.load -ef ${modules_dir}-available/${name}.load ]'",
                notify  => Service['apache'],
                require => Package['apache'],
            }
        }
        default : {
            exec { "/usr/sbin/a2enmod ${name}":
                unless  => "/bin/sh -c '[ -L ${modules_dir}-enabled/${name}.load ] \\
                    && [ ${modules_dir}-enabled/${name}.load -ef ${modules_dir}-available/${name}.load ]'",
                notify  => Service['apache'],
                require => $package_name ? {
                    'absent' => Package['apache'],
                    default  => Package[['apache',$package_name]],
                },
            }
        }
    }
}

