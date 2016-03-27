# configure a worker
class apache::centos::worker inherits apache::centos {

  if versioncmp($::operatingsystemmajrelease,'6') > 0 {
    File_line['mpm_prefork']{
      line  => '#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so',
    }
    File_line['mpm_event']{
      line  => 'LoadModule mpm_event_module modules/mod_mpm_event.so',
    }
  } else {
    File['apache_service_config']{
      source => "puppet:///modules/apache/service/${::operatingsystem}/httpd.worker"
    }
  }
}
