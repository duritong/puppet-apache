# manifests/joomla.pp

class apache::joomla {
    apache::config::file{'joomla.inc': }
}
