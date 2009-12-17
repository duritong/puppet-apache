class apache::debian::itk inherits apache::debian {
    include ::apache::base::itk
    Package['apache']{
        name => 'apache2-mpm-itk',
    }
}
