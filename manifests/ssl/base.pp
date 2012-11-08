class apache::ssl::base {
  ::apache::config::include{ 'ssl_defaults.inc': }

  if !$apache_no_default_site {
    ::apache::vhost::file{ '0-default_ssl': }
  }
}
