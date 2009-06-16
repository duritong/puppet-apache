class apache::mod_dav_svn {
    include apache
    package{mod_dav_svn:
        ensure => installed,
        require => Package['apache'],
        notify => Service['apache'],
    }
}
