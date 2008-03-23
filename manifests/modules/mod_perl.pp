# modules/apache/manifests/modules/mod_perl.pp
# 2008 - admin(at)immerda.ch
# License: GPLv3

class apache::mod_perl {
    case $operatingsystem {
        gentoo: { include apache::mod_perl::gentoo }
        default: { include apache::mod_perl::base }
    }
}

class apache::mod_perl::base {
    package{mod_perl:
        ensure => installed,
        notify => Service[apache],
    }
}

class apache::mod_perl::gentoo inherits apache::mod_perl::base {
    Package[mod_perl]{
        category => 'www-apache',
    }
}


