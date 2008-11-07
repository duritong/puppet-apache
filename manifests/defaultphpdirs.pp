# manifests/defaultphpdirs.pp

class apache::defaultphpdirs {
    file{'/var/www/upload_tmp_dir':
        ensure => directory,
        require => Package['apache'],
        owner => root, group => 0, mode => 0755;
    }
    file{'/var/www/session.save_path':
        ensure => directory,
        require => Package['apache'],
        owner => root, group => 0, mode => 0755;
    }
}
