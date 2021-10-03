# manages all resources related to a saml entity
define apache::module::auth_mellon::entity (
  Pattern[/^https:\/\//] $login_url,
  Array[String, 1]       $signing_certs,
  String                 $sp_key,
  String                 $sp_cert,
  String                 $idp_ca,
  String                 $entity_id = $title,
  Boolean                $binding_post = true,
  Boolean                $binding_redirect = false,
) {
  include apache::module::auth_mellon
  file {
    default:
      owner  => root,
      group  => apache,
      mode   => '0640',
      notify => Service['apache'];
    "/etc/httpd/mellon/${name}-idp-metadata.xml":
      content => template('apache/utils/idp-metadata.xml.erb');
    ["/etc/httpd/mellon/${name}.crt",
      "/etc/httpd/mellon/${name}.key",
    "/etc/httpd/mellon/${name}-ca.crt"]:;
  }

  ( { "/etc/httpd/mellon/${name}.crt" => $sp_cert,
      "/etc/httpd/mellon/${name}.key" => $sp_key,
      "/etc/httpd/mellon/${name}-ca.crt" => $idp_ca,
  }).each |$file, $val| {
    if $val =~ /^puppet:\/\// {
      File[$file] {
        source => $val,
      }
    } else {
      File[$file] {
        content => $val,
      }
    }
  }
}
