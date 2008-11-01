# manifests/ssl/itk.pp

class apache::ssl::itk inherits apache::ssl {
    case $operatingsystem {
        centos: { include apache::ssl::itk::centos }
    }
}

class apache::ssl::itk::centos inherits apache::ssl::centos {
    Package['mod_ssl']{
        name => 'mod_ssl-itk',
    }
}

