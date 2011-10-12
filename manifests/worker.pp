class apache::itk inherits apache {
  case $operatingsystem {
    centos: { include ::apache::centos::worker }
  }
}
