class apache::logrotate::centos {
    # add vhost folders to logrotation
    augeas{'logrotate_httpd':
      changes => [ 'rm /files/etc/logrotate.d/httpd/rule/file',
        'ins file before /files/etc/logrotate.d/httpd/rule/*[1]',
        'set /files/etc/logrotate.d/httpd/rule/file[1] /var/log/httpd/*log' ],
    }
}
