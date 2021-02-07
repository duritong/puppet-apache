# deploy a default include for joomla
class apache::include::joomla {
  apache::config::include_file { 'joomla.inc': }
}
