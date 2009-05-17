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

    File['htpasswd_dir']{
        mode => 0644,
    }
}

# http://hostby.net/home/2008/07/12/centos-5-and-mpm-itk/
class apache::centos::itk inherits apache::centos {
    Package['apache']{
        name => 'httpd-itk',
    }
    File['/etc/sysconfig/httpd']{
      source => [ "puppet://$server/files/apache/sysconfig/${fqdn}/httpd.itk",
                  "puppet://$server/files/apache/sysconfig/httpd.itk",
                  "puppet://$server/apache/sysconfig/${operatingsystem}/httpd.itk",
                  "puppet://$server/apache/sysconfig/httpd.itk" ],
    }
}
