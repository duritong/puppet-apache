# deploy a default include for silverstripe
class apache::include::silverstripe {
  apache::config::include{'silverstripe.inc': }
}
