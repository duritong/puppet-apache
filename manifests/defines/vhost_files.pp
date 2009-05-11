# manifests/defines/vhost_files.pp

### vhost configuration files
#
# deploy vhost configuration files


# this is a wrapper for apache::vhost::file and avhost::template below
#
# vhost_mode: which option is choosed to deploy the vhost
#   - template: generate it from a template (default)
#   - file: deploy a vhost file (apache::vhost::file will be called directly)
#   
define apache::vhost(
    $ensure = present,
    $path = 'absent',
    $path_is_webdir = false,
    $template_mode = 'static',
    $vhost_mode = 'template',
    $vhost_source = 'absent',
    $vhost_destination = 'absent',
    $content = 'absent',
    $domain = 'absent',
    $domainalias = 'absent',
    $server_admin = 'absent',
    $allow_override = 'None',
    $php_upload_tmp_dir = 'absent',
    $php_session_save_path = 'absent',
    $cgi_binpath = 'absent',
    $default_charset = 'absent',
    $do_includes = false,
    $options = 'absent',
    $additional_options = 'absent',
    $run_mode = 'normal',
    $run_uid = 'absent',
    $run_gid = 'absent',
    $template_mode = 'static',
    $ssl_mode = false,
    $htpasswd_file = 'absent',
    $htpasswd_path = 'absent',
    $mod_security = true,
    $ldap_auth = false,
    $ldap_user = 'any'
) {
    # file or template mode?
    case $vhost_mode {
        'file': {
            apache::vhost::file{$name:
                ensure => $ensure,
                vhost_source => $vhost_source,
                vhost_destination => $vhost_destination,
                do_includes => $do_includes,
                htpasswd_file => $htpasswd_file,
                htpasswd_path => $htpasswd_path,
            }
        }
        'template': {
            apache::vhost::template{$name:
                ensure => $ensure,
                path => $path,
                path_is_webdir => $path_is_webdir,
                domain => $domain,
                domainalias => $domainalias,
                server_admin => $server_admin,
                php_upload_tmp_dir => $php_upload_tmp_dir,
                php_session_save_path => $php_session_save_path,
                cgi_binpath => $cgi_binpath,
                allow_override => $allow_override,
                do_includes => $do_includes,
                options => $options,
                additional_options => $additional_options,
                default_charset => $default_charset,
                run_mode => $run_mode,
                run_uid => $run_uid,
                run_gid => $run_gid,
                template_mode => $template_mode,
                ssl_mode => $ssl_mode,
                htpasswd_file => $htpasswd_file,
                htpasswd_path => $htpasswd_path,
                ldap_auth => $ldap_auth,
                ldap_user => $ldap_user,
                mod_security => $mod_security,
            }
        }
        default: { fail("no such vhost_mode: $vhost_mode defined for $name.") }
    }
    
}

# htpasswd_file: wether to deploy a passwd for this vhost or not
#   - absent: ignore (default)
#   - nodeploy: htpasswd file isn't deployed by this mechanism
#   - else: try to deploy the file
#
# htpasswd_path: where to deploy the passwd file
#   - absent: standardpath (default)
#   - else: path to deploy
#
define apache::vhost::file(
    $ensure = present,
    $vhost_source = 'absent',
    $vhost_destination = 'absent',
    $content = 'absent',
    $do_includes = false,
    $htpasswd_file = 'absent',
    $htpasswd_path = 'absent'
){
    $vhosts_dir = $operatingsystem ? {
        centos => "$apache::centos::config_dir/vhosts.d/",
        gentoo => "$apache::gentoo::config_dir/vhosts.d/",
        debian => "$apache::debian::config_dir/vhosts.d/",
        ubuntu => "$apache::ubuntu::config_dir/vhosts.d/",
        openbsd => "$apache::openbsd::config_dir/vhosts.d/",
        default => '/etc/apache2/vhosts.d/',
    }
    $real_vhost_destination = $vhost_destination ? {
        'absent' => "$vhosts_dir/$name.conf",
        default => $vhost_destination,
    } 
    file{"${name}.conf":
        ensure => $ensure,
        path => $real_vhost_destination,
        require => File[vhosts_dir],
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }
    if $do_includes {
        include apache::includes 
    }
    case $content {
        'absent': {
            $real_vhost_source = $vhost_source ? {
                'absent'  => [ 
                    "puppet://$server/files/apache/vhosts.d/$fqdn/$name.conf",
                    "puppet://$server/files/apache/vhosts.d/$apache_cluster_node/$name.conf",
                    "puppet://$server/files/apache/vhosts.d/$operatingsystem.$lsbdistcodename/$name.conf",
                    "puppet://$server/files/apache/vhosts.d/$operatingsystem/$name.conf",
                    "puppet://$server/files/apache/vhosts.d/$name.conf", 
                    "puppet://$server/apache/vhosts.d/$name.conf",
                    "puppet://$server/apache/vhosts.d/$operatingsystem.$lsbdistcodename/$name.conf",
                    "puppet://$server/apache/vhosts.d/$operatingsystem/$name.conf",
                    "puppet://$server/apache/vhosts.d/$name.conf"
                ],
                default => "puppet://$server/$vhost_source",
            }
            File["${name}.conf"]{
                source => $real_vhost_source,
            }
        }
        default: {
            File["${name}.conf"]{
                content => $content,
            }
        }
    }
    case $htpasswd_file {
        'absent','nodeploy': { info("don't deploy a htpasswd file for ${name") }
        default: { 
            case $htpasswd_path {
                'absent': {
                    $real_htpasswd_path = $operatingsystem ? {
                        gentoo => "$apache::gentoo::config_dir/htpasswds/$name",
                        debian => "$apache::debian::config_dir/htpasswds/$name",
                        ubuntu => "$apache::ubuntu::config_dir/htpasswds/$name",
                        openbsd => "$apache::openbsd::config_dir/htpasswds/$name",
                        default => "/etc/apache2/htpasswds/$name"
                    }
                }
                default: { $real_htpasswd_path = $htpasswd_path }
            }
            file{$real_htpasswd_path:
                ensure => $ensure,
                source => [ "puppet://$server/files/apache/htpasswds/$fqdn/$name",
                            "puppet://$server/files/apache/htpasswds/$apache_cluster_node/$name",
                            "puppet://$server/files/apache/htpasswds/$name" ],
                owner => root, group => 0, mode => 0644;
            }
        }
    }
}

# template_mode:
#   - php: for a default php application
#   - static: for a static application (default)
#   - perl: for a mod_perl application
#   - php_joomla: for a joomla application
#
# domainalias:
#   - absent: no domainalias is set (*default*)
#   - www: domainalias is set to www.$domain
#   - else: domainalias is set to that
#
# ssl_mode: wether this vhost supports ssl or not
#   - false: don't enable ssl for this vhost (default)
#   - true: enable ssl for this vhost
#   - force: enable ssl and redirect non-ssl to ssl
#
define apache::vhost::template(
    $ensure = present,
    $path = 'absent',
    $path_is_webdir = false,
    $domain = 'absent',
    $domainalias = 'absent',
    $server_admin = 'absent',
    $allow_override = 'None',
    $php_upload_tmp_dir = 'absent',
    $php_session_save_path = 'absent',
    $cgi_binpath = 'absent',
    $do_includes = false,
    $options = 'absent',
    $additional_options = 'absent',
    $default_charset = 'absent',
    $run_mode = 'normal',
    $run_uid = 'absent',
    $run_gid = 'absent',
    $template_mode = 'static', 
    $ssl_mode = false,
    $mod_security = true,
    $htpasswd_file = 'absent',
    $htpasswd_path = 'absent',
    $ldap_auth = false,
    $ldap_user = 'any'
){
    $real_path = $path ? {
        'absent' => $operatingsystem ? {
            openbsd => "/var/www/htdocs/$name",
            default => "/var/www/vhosts/$name"
        },
        default => $path
    }

    if $path_is_webdir {
        $documentroot = "$real_path"
    } else {
        $documentroot = "$real_path/www"
    }
    $logdir = "$real_path/logs"

    $servername = $domain ? {
        'absent' => $name,
        default => $domain
    }
    $serveralias = $domainalias ? {
        'absent' => '',
        'www' => "www.${servername}",
        default => $domainalias
    }
    case $htpasswd_path {
        'absent': {
            $real_htpasswd_path = $operatingsystem ? {
                gentoo => "$apache::gentoo::config_dir/htpasswds/$name",
                debian => "$apache::debian::config_dir/htpasswds/$name",
                ubuntu => "$apache::ubuntu::config_dir/htpasswds/$name",
                openbsd => "$apache::openbsd::config_dir/htpasswds/$name",
                default => "/etc/apache2/htpasswds/$name"
            }
        }
        default: { $real_htpasswd_path = $htpasswd_path }
    }
    case $run_mode {
        'itk': {
            case $run_uid {
                'absent': { fail("you have to define run_uid for $name on $fqdn") }
            }
            case $run_gid {
                'absent': { fail("you have to define run_gid for $name on $fqdn") }
            }
        }
    }

    # set default dirs for templates
    # php upload_tmp_dir
    case $php_upload_tmp_dir {
        'absent': {
            $real_php_upload_tmp_dir = "/var/www/upload_tmp_dir/$name"
        }
        default: { $real_php_upload_tmp_dir = $php_upload_tmp_dir }
    }
    # php session_save_path
    case $php_session_save_path {
        'absent': {
            $real_php_session_save_path = "/var/www/session.save_path/$name"
        }
        default: { $real_php_session_save_path = $php_session_save_path }
    }

    apache::vhost::file{$name:
        ensure => $ensure,
        content => template("apache/vhosts/$template_mode/$operatingsystem.erb"),
        do_includes => $do_includes,
        htpasswd_file => $htpasswd_file,
        htpasswd_path => $htpasswd_path,
    }
}


define apache::vhost::file::documentrootfile(
      $documentroot,
      $filename,
      $thedomain,
      $owner='root',
      $group='0',
      $mode=440
){
    file{"$documentroot/$filename":
        source  => [ "puppet://$server/files/apache/vhost_varieties/$fqdn/$thedomain/$filename",
                    "puppet://$server/files/apache/vhost_varieties/$apache_cluster_node/$thedomain/$filename",
                    "puppet://$server/files/apache/vhost_varieties/$operatingsystem.$lsbdistcodename/$thedomain/$filename",
                    "puppet://$server/files/apache/vhost_varieties/$operatingsystem/$thedomain/$filename",
                    "puppet://$server/files/apache/vhost_varieties/$thedomain/$filename",
                    "puppet://$server/apache/vhost_varieties/$thedomain/$filename",
                    "puppet://$server/apache/vhost_varieties/$operatingsystem.$lsbdistcodename/$thedomain/$filename",
                    "puppet://$server/apache/vhost_varieties/$operatingsystem/$thedomain/$filename",
                    "puppet://$server/apache/vhost_varieties/$thedomain/$filename"
                   ],
        ensure  => file,
        require => Apache::Vhost::Webdir["$thedomain"],
        owner => $owner, group => $group, mode => $mode;
    }
}

define apache::vhost::file::documentrootdir(
      $ensure = directory,
      $documentroot,
      $filename,
      $thedomain,
      $owner = 'root',
      $group = '0',
      $mode = 440
){
  file{"$documentroot/$filename":
    require => Apache::Vhost::Webdir["$thedomain"],
    owner => $owner, group => $group, mode => $mode;
  }
  if $ensure != 'absent' {
    File["$documentroot/$filename"]{
      ensure => directory,
    }
  } else {
    File["$documentroot/$filename"]{
      ensure => $ensure,
    }
  }
}



define apache::vhost::phpdirs(
    $ensure = present,
    $php_upload_tmp_dir = 'absent',
    $php_session_save_path = 'absent',
    $documentroot_owner = apache,
    $documentroot_group = 0,
    $documentroot_mode = 0750,
    $run_mode = 'normal',
    $run_uid = 'absent'
){
    # php upload_tmp_dir
    case $php_upload_tmp_dir {
        'absent': {
            include apache::defaultphpdirs
            $real_php_upload_tmp_dir = "/var/www/upload_tmp_dir/$name"
        }
        default: { $real_php_upload_tmp_dir = $php_upload_tmp_dir }
    }
    # php session_save_path
    case $php_session_save_path {
        'absent': {
            include apache::defaultphpdirs
            $real_php_session_save_path = "/var/www/session.save_path/$name"
        }
        default: { $real_php_session_save_path = $php_session_save_path }
    }

    case $ensure {
        absent: {
            file{[$real_php_upload_tmp_dir, $real_php_session_save_path ]:
                ensure => absent,
                purge => true,
                force => true,
                recurse => true,
            }
        }
        default: {
            file{[$real_php_upload_tmp_dir, $real_php_session_save_path ]:
                ensure => directory,
                owner => $run_mode ? {
                    'itk' => $run_uid,
                    default => $documentroot_owner
                },
                group => $documentroot_group, mode => $documentroot_mode;
            }
        }
    }
}
