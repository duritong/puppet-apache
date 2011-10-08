class apache::include::mod_fcgid {
  apache::config::global{'mod_fcgid':
    content => "FcgidFixPathinfo 1\n"
  }
}