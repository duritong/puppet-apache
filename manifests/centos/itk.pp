# http://hostby.net/home/2008/07/12/centos-5-and-mpm-itk/
class apache::centos::itk inherits apache::centos {
    include ::apache::base::itk
    Package['apache']{
        name => 'httpd-itk',
    }
    File['apache_service_config']{
      source => [ "puppet://$server/modules/site-apache/service/CentOS/${fqdn}/httpd.itk",
                  "puppet://$server/modules/site-apache/service/CentOS/httpd.itk",
                  "puppet://$server/modules/apache/service/CentOS/httpd.itk" ],
    }
}
