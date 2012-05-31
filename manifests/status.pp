# manifests/status.pp

class apache::status {
    case $::operatingsystem {
        centos: { include apache::status::centos }
        defaults: { include apache::status::base }
    }
    if hiera('use_munin',false) {
        include munin::plugins::apache
    }
}

