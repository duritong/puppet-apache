# manifests/joomla.pp

class apache::joomla {
    apache::config::include{'joomla.inc': }
}
