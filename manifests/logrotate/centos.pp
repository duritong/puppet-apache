# remove vhost folders from logrotation
class apache::logrotate::centos {
  augeas{'logrotate_httpd':
    incl    => '/etc/logrotate.d/httpd',
    lens    => 'Logrotate.lns',
    changes => [ 'rm /files/etc/logrotate.d/httpd/rule/file',
      'ins file before /files/etc/logrotate.d/httpd/rule/*[1]',
      'set /files/etc/logrotate.d/httpd/rule/file[1] /var/log/httpd/*log' ],
    onlyif  => 'get /files/etc/logrotate.d/httpd/rule/file[1] != "/var/log/httpd/*log"',
    require => Package['apache'],
  }
}
