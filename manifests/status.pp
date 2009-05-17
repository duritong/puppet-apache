# manifests/status.pp

class apache::status inherits apache {
    case $operatingsystem {
        centos: { include apache::status::centos }
        defaults: { include apache::status::base }
    }
    if $use_munin {
        include munin::plugins::apache
    }
}

