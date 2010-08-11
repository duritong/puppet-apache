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
    $htpasswd_path = 'absent',
    $use_mod_macro = false
){
    $vhosts_dir = $operatingsystem ? {
        centos => "$apache::centos::config_dir/vhosts.d",
        gentoo => "$apache::gentoo::config_dir/vhosts.d",
        debian => "$apache::debian::config_dir/sites-enabled",
        ubuntu => "$apache::ubuntu::config_dir/sites-enabled",
        openbsd => "$apache::openbsd::config_dir/vhosts.d",
        default => '/etc/apache2/vhosts.d',
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
        include ::apache::includes
    }
    if $use_mod_macro {
        include ::apache::mod_macro
    }
    if $ensure != 'absent' {
      case $content {
        'absent': {
            $real_vhost_source = $vhost_source ? {
                'absent'  => [
                    "puppet:///modules/site-apache/vhosts.d/$fqdn/$name.conf",
                    "puppet:///modules/site-apache/vhosts.d/$apache_cluster_node/$name.conf",
                    "puppet:///modules/site-apache/vhosts.d/$operatingsystem.$lsbdistcodename/$name.conf",
                    "puppet:///modules/site-apache/vhosts.d/$operatingsystem/$name.conf",
                    "puppet:///modules/site-apache/vhosts.d/$name.conf",
                    "puppet:///modules/apache/vhosts.d/$operatingsystem.$lsbdistcodename/$name.conf",
                    "puppet:///modules/apache/vhosts.d/$operatingsystem/$name.conf",
                    "puppet:///modules/apache/vhosts.d/$name.conf"
                ],
                default => "puppet:///$vhost_source",
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
    }
    case $htpasswd_file {
        'absent','nodeploy': { info("don't deploy a htpasswd file for ${name}") }
        default: {
            if $htpasswd_path == 'absent' {
                $real_htpasswd_path = "/var/www/htpasswds/$name"
            } else {
                $real_htpasswd_path = $htpasswd_path
            }
            file{$real_htpasswd_path:
                ensure => $ensure,
                source => [ "puppet:///modules/site-apache/htpasswds/$fqdn/$name",
                            "puppet:///modules/site-apache/htpasswds/$apache_cluster_node/$name",
                            "puppet:///modules/site-apache/htpasswds/$name" ],
                owner => root, group => 0, mode => 0644;
            }
        }
    }
}

