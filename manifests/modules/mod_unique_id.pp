# modules/apache/manifests/modules/mod_unique_id.pp
# 2008 - admin(at)immerda.ch
# License: GPLv3

class apache::mod_unique_id {
    case $operatingsystem {
        default: { include apache::mod_unique_id::base }
    }
}

class apache::mod_security::base {
    #noting todo yet
}

