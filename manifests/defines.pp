# manifests/defines.pp

# This file contains various defines to work with apache.
# They are separated into various categories:
# 
# - common vhosts
# - vhost deploy
# - configuration defines
# - wrapper defines

### common vhosts

# vhost_mode: which option is choosed to deploy the vhost
#   - template: generate it from a template (default)
#   - file: deploy a vhost file (apache::vhost::file will be called directly)
#   
define apache::vhost::static(
    $domain = 'absent',
    $domainalias = 'absent',
    $path = 'absent',
    $owner = root,
    $group = 0,
    $mode = 0640,
    $apache_user = apache,
    $apache_group = 0,
    $apache_mode = 0640,
    $allow_override = 'None',
    $additional_options = 'absent',
    $vhost_mode = 'template',
    $vhost_source = 'absent',
    $vhost_destination = 'absent'
){
    $real_path = $path ? {
        'absent' => $operatingsystem ? {
            openbsd => "/var/www/htdocs/${name}",
            default => "/var/www/${name}"
        },
        default => "${path}"
    }
    $documentroot = "${real_path}/www"
    $logdir = "${real_path}/logs"

    apache::vhost::webhostdir{$name:
        path => $path,
        owner => $owner,
        group => $group,
        mode => $mode,
        apache_user => $apache_user,
        apache_group => $apache_group,
    }

    apache::vhost{"${name}":
        vhost_mode => $vhost_mode,
        source => $vhost_source,
        destination => $vhost_destination,
        domain => $domain,
        domainalias => $domainalias,
        allow_override => $allow_override,
        additional_options => $additional_options,
        template_mode => 'static',
        ssl_mode => $ssl_mode,
        mod_security => 'false',
    }
}

define apache::vhost::php::standard(
    $domain = 'absent',
    $domainalias = 'absent',
    $path = 'absent',
    $owner = root,
    $group = 0,
    $mode = 0640,
    $apache_user = apache,
    $apache_group = 0,
    $apache_mode = 0640,
    $allow_override = 'None',
    $upload_tmp_dir = 'absent',
    $session_save_path = 'absent',
    $additional_options = 'absent',
    $mod_security = 'true',
    $vhost_mode = 'template',
    $vhost_source = 'absent',
    $vhost_destination = 'absent'
){
    $real_path = $path ? {
        'absent' => $operatingsystem ? {
            openbsd => "/var/www/htdocs/${name}",
            default => "/var/www/${name}"
        },
        default => "${path}"
    }
    $documentroot = "${real_path}/www"
    $logdir = "${real_path}/logs"

    apache::vhost::webhostdir{$name:
        path => $path,
        owner => $owner,
        group => $group,
        mode => $mode,
        apache_user => $apache_user,
        apache_group => $apache_group,
    }

    case $upload_tmp_dir {
        'absent': {
            include apache::defaultphpdirs
            $real_upload_tmp_dir = "/var/www/upload_tmp_dir/${name}"
        }
        default: {
            $real_upload_tmp_dir = $upload_tmp_dir
        }
    }
    file{"$upload_tmp_dir":
        ensure => directory,
        owner => $apache_user, group => $apache_group, mode => $apache_mode;
    }

    case $session_save_path {
        'absent': {
            include apache::defaultphpdirs
            $real_session_save_path = "/var/www/session.save_path/${name}"
        }
        default: {
            $real_session_save_path = $session_save_path
        }
    }
    file{"$session_save_path":
        ensure => directory,
        owner => $apache_user, group => $apache_group, mode => $apache_mode;
    }

    apache::vhost{"${name}":
        template_mode => 'php',
        vhost_mode => $vhost_mode,
        source => $vhost_source,
        destination => $vhost_destination,
        domain => $domain,
        domainalias => $domainalias,
        allow_override => $allow_override,
        additional_options => $additional_options,
        template_mode => 'php',
        php_upload_tmp_dir => $real_upload_tmp_dir,
        php_session_save_path => $real_session_save_path,
        ssl_mode => $ssl_mode,
        mod_security => $mod_security,
    }

}

### vhost deploy stuff
# these defines are used to deploy a vhost file

# This define is used to wrap the other vhost defines.
#
# vhost_mode: which option is choosed to deploy the vhost
#   - template: generate it from a template (default)
#   - file: deploy a vhost file (apache::vhost::file will be called directly)
#   
define apache::vhost(
    $template_mode = 'static',
    $vhost_mode = 'template',
    $source = 'absent',
    $destination = 'absent',
    $content = 'absent',
    $domain = 'absent',
    $domainalias = 'absent',
    $allow_override = 'None',
    $php_upload_tmp_dir = 'absent',
    $php_session_save_path = 'absent',
    $additional_options = 'absent',
    $template_mode = 'static',
    $ssl_mode = 'false',
    $mod_security = 'true'
) {
    case $vhost_mode {
        'file': {
            apache::vhost::file{"${name}":
                source => $vhost_source,
                destination => $vhost_destination,
            }
        }
        'template': {
            apache::vhost::template{"${name}":
                domain => $domain,
                domainalias => $domainalias,
                php_upload_tmp_dir => $php_upload_tmp_dir,
                php_session_save_path => $php_session_save_path,
                allow_override => $allow_override,
                additional_options => $additional_options,
                template_mode => $template_mode,
                ssl_mode => $ssl_mode,
                mod_security => 'false',
            }
        }
        default: { fail("no such vhost_mode: ${vhost_mode} defined for ${name}.") }
    }
    
}

define apache::vhost::file(
    $source = 'absent',
    $destination = 'absent',
    $content = 'absent'
){
    $vhosts_dir = $operatingsystem ? {
        centos => "$apache::centos::config_dir/vhosts.d/",
        gentoo => "$apache::gentoo::config_dir/vhosts.d/",
        debian => "$apache::debian::config_dir/vhosts.d/",
        ubuntu => "$apache::ubuntu::config_dir/vhosts.d/",
        openbsd => "$apache::openbsd::config_dir/vhosts.d/",
        default => '/etc/apache2/vhosts.d/',
    }
    $real_destination = $destination ? {
        'absent' => "${vhosts_dir}/${name}.conf",
        default => $destination,
    } 
    file{"${name}.conf":
        path => $real_destination,
        require => File[vhosts_dir],
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }
    case $content {
        'absent': {
            $real_source = $source ? {
                'absent'  => [ 
                    "puppet://$server/files/apache/vhosts.d/${fqdn}/${name}.conf",
                    "puppet://$server/files/apache/vhosts.d/${apache_cluster_node}/${name}.conf",
                    "puppet://$server/files/apache/vhosts.d/${name}.conf", 
                    "puppet://$server/apache/vhosts.d/${name}.conf",
                    "puppet://$server/apache/vhosts.d/${operatingsystem}.${lsbdistcodename}/${name}.conf",
                    "puppet://$server/apache/vhosts.d/${operatingsystem}/${name}.conf",
                    "puppet://$server/apache/vhosts.d/${name}.conf"
                ],
                default => "puppet://$server/$source",
            }
            File["${name}.conf"]{
                source => $real_source,
            }
        }
        default: {
            File["${name}.conf"]{
                content => $content,
            }
        }
    }
}


# template_mode:
#   - php -> for a default php application
#   - static -> for a static application (default)
# ssl_mode: wether this vhost supports ssl or not
#   - false: don't enable ssl for this vhost (default)
#   - true: enable ssl for this vhost
#   - force: enable ssl and redirect non-ssl to ssl
define apache::vhost::template(
    $domain = 'absent',
    $domainalias = 'absent',
    $allow_override = 'None',
    $php_upload_tmp_dir = 'absent',
    $php_session_save_path = 'absent',
    $additional_options = 'absent',
    $template_mode = 'static', 
    $ssl_mode = 'false',
    $mod_security = 'true'
){
    $servername = $domain ? {
        'absent' => $name,
        default => $domain
    }
    $serveralias = $domainalias ? {
        'absent' => '',
        default => $domainalias
    }

    apache::vhost::file{"$name":
        content => template("apache/vhosts/${templapte_mode}/${operatingsystem}.erb"),
    }
}

### configuration defines
# These defines are used to configured the apache
#

define apache::config::file(
    $source = '',
    $destination = ''
){
    $real_source = $source ? {
        # get a whole bunch of possible sources if there is no specific source for that config-file
        '' => [ 
            "puppet://$server/files/apache/conf.d/${fqdn}/${name}",
            "puppet://$server/files/apache/conf.d/${apache_cluster_node}/${name}",
            "puppet://$server/files/apache/conf.d/${name}",
            "puppet://$server/apache/conf.d/${operatingsystem}.${lsbdistcodename}/${name}",
            "puppet://$server/apache/conf.d/${operatingsystem}/${name}",
            "puppet://$server/apache/conf.d/${name}"
        ],
        default => "puppet://$server/$source",
    }
    $real_destination = $destination ? {
        '' => $operatingsystem ? {
            centos => "$apache::centos::config_dir/conf.d/${name}",
            gentoo => "$apache::gentoo::config_dir/${name}",
            debian => "$apache::debian::config_dir/conf.d/${name}",
            ubuntu => "$apache::ubuntu::config_dir/conf.d/${name}",
            openbsd => "$apache::openbsd::config_dir/conf.d/${name}",
            default => "/etc/apache2/${name}",
        },
        default => $destination
    }
    file{"apache_${name}":
        path => $real_destination,
        source => $real_source,
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }

    case $operatingsystem {
        openbsd: { info("no package dependency on ${operatingsystem} for ${name}") }
        default: {
            File["apache_${name}"]{
                require => Package[apache],
            }
        }
    }
}

define apache::centos::module(
    $source = '',
    $destination = ''
){
    $modules_dir = "$apache::centos::config_dir/modules.d/"
    $real_destination = $destination ? {
        '' => "${modules_dir}/${name}.so",
        default => $destination,
    }
    $real_source = $source ? {
        ''  => [
            "puppet://$server/files/apache/modules.d/${fqdn}/${name}.so",
            "puppet://$server/files/apache/modules.d/${apache_cluster_node}/${name}.so",
            "puppet://$server/files/apache/modules.d/${name}.so",
            "puppet://$server/apache/modules.d/${operatingsystem}/${name}.so",
            "puppet://$server/apache/modules.d/${name}.so"
        ],
        default => "puppet://$server/$source",
    }
    file{"modules_${name}.conf":
        path => $real_destination,
        source => $real_source,
        require => [ File[modules_dir], Package[apache] ],
        notify => Service[apache],
        owner => root, group => 0, mode => 0755;
    }
}


define apache::gentoo::module(
    $source = '',
    $destination = ''
){
    $modules_dir = "$apache::gentoo::config_dir/modules.d/"
    $real_destination = $destination ? {
        '' => "${modules_dir}/${name}.conf",
        default => $destination,
    }
    $real_source = $source ? {
        ''  => [
            "puppet://$server/files/apache/modules.d/${fqdn}/${name}.conf",
            "puppet://$server/files/apache/modules.d/${apache_cluster_node}/${name}.conf",
            "puppet://$server/files/apache/modules.d/${name}.conf",
            "puppet://$server/apache/modules.d/${operatingsystem}/${name}.conf",
            "puppet://$server/apache/modules.d/${name}.conf"
        ],
        default => "puppet://$server/$source",
    }
    file{"modules_${name}.conf":
        path => $real_destination,
        source => $real_source,
        require => [ File[modules_dir], Package[apache] ],
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }
}


### wrapper defines
# These defines are mostly wrappers for the common setup.
# They are mainly called by the other defines


define apache::vhost::webhostdir(
    $path = 'absent',
    $owner = root,
    $group = 0,
    $mode = 0640,
    $apache_user = apache,
    $apache_group = 0
){
    $real_path = $path ? {
        'absent' => $operatingsystem ? {
            openbsd => "/var/www/htdocs/${name}",
            default => "/var/www/${name}"
        },
        default => "${path}"
    }
    $documentroot = "${real_path}/www"
    $logdir = "${real_path}/logs"

    case $apache_user {
        apache: {
            case $apache_default_user {
                '': { 
                    $real_apache_user = $operatingsystem ? {
                        openbsd => 'nobody',
                        default => $apache_user 
                    }
                }
                default: { $real_apache_user = $apache_default_user }
            }
        }
        default: { $real_apache_user = $apache_default_user }
    }

    case $apache_group {
        apache: {
            case $apache_default_group {
                '': {
                    $real_apache_group = $operatingsystem ? {
                        openbsd => 'nobody',
                        default => $apache_group
                    }
                }
                default: { $real_apache_group = $apache_default_group }
            }
        }
        default: { $real_apache_group = $apache_default_group }
    }

    file{ [ "$real_path", "$documentroot" ] :
        ensure => directory,
        owner => $owner, group => $real_apache_group, mode => $mode;
    }

    # the logdir must be writeable by the apache and the user
    file{"$logdir":
        ensure => directory,
        owner => $real_apache_user, group => $group, mode => 775;
    }
}
