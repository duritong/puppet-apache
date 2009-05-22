# http://hostby.net/home/2008/07/12/centos-5-and-mpm-itk/
class apache::centos::itk inherits apache::centos {
    include ::apache::package::itk
    File['/etc/sysconfig/httpd']{
      source => [ "puppet://$server/files/apache/sysconfig/${fqdn}/httpd.itk",
                  "puppet://$server/files/apache/sysconfig/httpd.itk",
                  "puppet://$server/apache/sysconfig/${operatingsystem}/httpd.itk",
                  "puppet://$server/apache/sysconfig/httpd.itk" ],
    }
}
