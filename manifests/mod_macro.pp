class apache::mod_macro {
    include apache
    package{mod_macro:
        ensure => installed,
        require => Package['apache'],
        notify => Service['apache'],
    }
}
