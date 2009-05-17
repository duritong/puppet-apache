class apache::base::itk inherits apache::base {
    Package['apache'] {
        name => 'apache2-itk',
    }

    File['htpasswd_dir']{
        group => 0,
        mode => 0644,
    }
}
