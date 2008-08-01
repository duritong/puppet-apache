# manifests/itk.pp
#
# see: http://mpm-itk.sesse.net/

class apache::itk inherits apache {
    case $operatingsystem {
        centos: { include apache::centos::itk }
        default: { include apache::base::itk }
    }
}

class apache::base::itk inherits apache::base {
    Package['apache'] {
        name => 'apache2-itk',
    }
}

# http://hostby.net/home/2008/07/12/centos-5-and-mpm-itk/
class apache::centos::itk inherits apache::centos {
    Package['apache']{
        name => 'httpd-itk',
    }

    Package['mod_ssl']{
        name => 'mod_ssl-itk',
    }
}
