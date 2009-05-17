# manifests/selinux.pp
# manage selinux specific stuff

class apache::selinux {
    case $operatingsystem {
        gentoo: { include apache::selinux::gentoo }
        default: { include apache::selinux::base }
    }
}
