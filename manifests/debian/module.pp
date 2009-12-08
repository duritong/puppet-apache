define apache::debian::module(
    $ensure = present
){
    $modules_dir = "$apache::debian::config_dir/mods"

    case $ensure {
        'present' : {
            exec { "/usr/sbin/a2enmod $name":
                unless => "/bin/sh -c '[ -L ${modules_dir}-enabled/${name}.load ] \\
                    && [ ${modules_dir}-enabled/${name}.load -ef ${modules_dir}-available/${name}.load ]'",
                notify => Service['apache'],
                require => Package['apache'],
            }
        }
        'absent': {
            exec { "/usr/sbin/a2dismod $name":
                onlyif => "/bin/sh -c '[ -L ${modules_dir}-enabled/${name}.load ] \\
                    && [ ${modules_dir}-enabled/${name}.load -ef ${modules_dir}-available/${name}.load ]'",
                notify => Service['apache'],
                require => Package['apache'],
            }
        }
    }
}

