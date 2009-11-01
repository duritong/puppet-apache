# http://hostby.net/home/2008/07/12/centos-5-and-mpm-itk/
class apache::centos::itk inherits apache::centos {
    include ::apache::base::itk
    Package['apache']{
        name => 'httpd-itk',
    }
    File['/etc/sysconfig/httpd']{
      source => [ "puppet://$server/files/apache/sysconfig/${fqdn}/httpd.itk",
                  "puppet://$server/files/apache/sysconfig/httpd.itk",
                  "puppet://$server/modules/apache/sysconfig/${operatingsystem}/httpd.itk",
                  "puppet://$server/modules/apache/sysconfig/httpd.itk" ],
    }
}
