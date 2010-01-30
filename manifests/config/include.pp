# deploy apache configuration file (includes for vhosts)
define apache::config::include(
    $ensure = present,
    $source = 'absent',
    $content = 'absent',
    $destination = 'absent'
){
    apache::config::file { "${name}":
        ensure => $ensure,
        type => 'include',
        source => $source,
        content => $content,
        destination => $destination,
    }
}
