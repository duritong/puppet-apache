# modules/apache/manifests/modules/mod_security.pp
# 2008 - admin(at)immerda.ch
# License: GPLv3

class apache::mod_security {
    case $operatingsystem {
        gentoo: { include apache::mod_security::gentoo }
        default: { include apache::mod_security::base }
    }
}

class apache::mod_security::base {
    #mod_unique_id is needed for mod_security
    include mod_unique_id

    package{mod_security:
        ensure => installed,
        notify => Service[apache],
    }
#    file{custom_rule_dir:
#        path => "/etc/apache2/modules.d/mod_security/Zcustom_rules",
#        ensure => directory,
#        owner => root,
#        group => 0,
#        mode => 755,
#        require => Package[mod_security],
#        notify => Service[apache],
#    }

    file{custom_rules:
        path => "/etc/apache2/modules.d/mod_security/Zcustom_rules/",
        source => "puppet://$server/apache/mod_security/custom_rules/",
        recurse => true,
        owner => root,
        group => 0,
        mode => 644,
        require => Package[mod_security],
        notify => Service[apache],
    }

#    file{custom_host_rules:
#        path => "/etc/apache2/modules.d/mod_security/Zcustom_rules/",
#        source => [ "puppet://$server/dist/apache/mod_security/custom_rules/${fqdn}",
#                    "puppet://$server/apache/mod_security/custom_rules.Default_keep_it_empty/" ],
#        recurse => true,
#        owner => root,
#        group => 0,
#        mode => 644,
#        require => File[custom_rule_dir],
#        notify => Service[apache],
#    }
}

class apache::mod_security::gentoo inherits apache::mod_security::base {
    Package[mod_security]{
        category => 'www-apache',
    }

    file{"/etc/apache2/modules.d/99_mod_security.conf":
        source => "puppet://$server/apache/mod_security/configs/gentoo/99_mod_security.conf",
        owner => root,
        group => 0,
        mode => 644,
        require => Package[mod_security],
        notify => Service[apache],
    }
}


