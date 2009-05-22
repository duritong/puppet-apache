# manifests/itk.pp
#
# see: http://mpm-itk.sesse.net/

class apache::itk inherits apache {
    case $operatingsystem {
        centos: { include apache::itk::centos }
        default: { include apache::base::itk }
    }
}
