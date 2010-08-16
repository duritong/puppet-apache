# http://hostby.net/home/2008/07/12/centos-5-and-mpm-itk/
class apache::centos::itk_plus inherits apache::centos::itk {
  Line['pidfile_httpd.conf','listen_httpd.conf']{
    ensure => absent,
  }

  Apache::Config::Global['00-listen.conf']{
    ensure => present,
    content => template("apache/itk_plus/${operatingsystem}/00-listen.conf.erb"),
  }

  File['apache_service_config']{
    source => "puppet:///modules/apache/service/CentOS/httpd.itk_plus"
  }
}
