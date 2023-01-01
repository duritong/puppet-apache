# add vhost folders to logrotation + su for newer logrotates
class apache::logrotate::centos::vhosts inherits apache::logrotate::centos {
  Augeas['logrotate_httpd'] {
    changes => ['rm /files/etc/logrotate.d/httpd/rule/file',
      'ins file before /files/etc/logrotate.d/httpd/rule/*[1]',
      'ins file before /files/etc/logrotate.d/httpd/rule/*[1]',
      'set /files/etc/logrotate.d/httpd/rule/file[1] /var/log/httpd/*log',
    'set /files/etc/logrotate.d/httpd/rule/file[2] /var/www/vhosts/*/logs/{access,error,mod_security}*log'],
    onlyif => 'get /files/etc/logrotate.d/httpd/rule/file[2] != "/var/www/vhosts/*/logs/{access,error,mod_security}*log"',
  }
  if versioncmp($facts['os']['release']['major'],'6') > 0 {
    augeas { 'logrotate_httpd_su':
      context => '/files/etc/logrotate.d/httpd/rule/',
      incl    => '/etc/logrotate.d/httpd',
      lens    => 'Logrotate.lns',
      require => Package['apache'],
      changes => [
        'set su/owner root',
        'set su/group root',
      ],
    }
  }
}
