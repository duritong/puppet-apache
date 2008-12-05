# manifests/includes.pp

class apache::includes {
    apache::config::file{'do_includes.conf':}
}
