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

class apache::status::base {}


### distribution specific classes

### centos
class apache::status::centos {
    apache::config::file{ 'status.conf': }
}
