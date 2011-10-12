class apache::centos::worker inherits apache::centos {
    File['apache_service_config']{
      source => "puppet:///modules/apache/service/CentOS/httpd.worker"
    }
}
