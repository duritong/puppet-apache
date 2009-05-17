class apache::selinux::gentoo inherits apache::selinux::base {
    package{'selinux-apache':
        ensure => present,
        category => 'sec-policy',
    }
    selinux::loadmodule {"apache": }
}
