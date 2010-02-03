class apache::ssl::debian inherits apache::ssl::base {
    apache::debian::module { 'ssl': ensure => present }
}
