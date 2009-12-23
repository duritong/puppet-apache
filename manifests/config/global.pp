# deploy apache configuration file (global)
# wrapper for apache::config::file
define apache::config::global(
    $ensure = present,
    $source = 'absent',
    $content = 'absent',
    $destination = 'absent'
){
    apache::config::file { "${name}":
        ensure => $ensure,
        source => $source,
        content => $content,
        destination => $destination,
    }
}
