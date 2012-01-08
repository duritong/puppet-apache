class apache::include::mod_fcgid {
  apache::config::global{'mod_fcgid.conf':
    content => "FcgidFixPathinfo 1\n"
  }
}
