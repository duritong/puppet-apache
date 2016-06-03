# deploy a default include for silverstripe
class apache::include::silverstripe {
  apache::config::include{'silverstripe.inc':
    content => template('apache/include.d/silverstripe.inc.erb')
  }
}
