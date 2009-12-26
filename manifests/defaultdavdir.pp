# manifests/defaultphpdirs.pp

class apache::defaultdavdir {
    file{'/var/www/dav_db_dir':
        ensure => directory,
        require => Package['apache'],
        owner => root, group => 0, mode => 0755;
    }
}
