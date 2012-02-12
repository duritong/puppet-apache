class apache::defaultphpdirs {
    file{
      '/var/www/upload_tmp_dir':
        ensure => directory,
        require => Package['apache'],
        owner => root, group => 0, mode => 0755;
      '/var/www/session.save_path':
        ensure => directory,
        require => Package['apache'],
        owner => root, group => 0, mode => 0755;
    }

    if $::selinux != 'false' {
      selinux::fcontext{
        ['/var/www/upload_tmp_dir/.+(/.*)?',
         '/var/www/session.save_path/.+(/.*)?']:
          setype => 'httpd_sys_rw_content_t',
          before => File['/var/www/upload_tmp_dir','/var/www/session.save_path'];
      }
    }
}
