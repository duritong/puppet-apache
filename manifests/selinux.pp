# manifests/selinux.pp
# manage selinux specific stuff

class apache::selinux {
    case $operatingsystem {
        gentoo: { include apache::selinux::gentoo }
        default: { include apache::selinux::base }
    }
}

class apache::selinux::base {}

class apache::selinux::gentoo inherits apache::selinux::base {
    selinux::loadmodule {"apache": location => "/usr/share/selinux/${selinux_mode}/apache.pp" }
    gentoo::installselinuxpackage { "selinux-apache": }
}
