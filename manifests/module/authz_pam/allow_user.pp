# enables a user for authz pam
define apache::module::authz_pam::allow_user (
  String[1] $user = $title,
  String[1] $pam_service = 'httpd',
) {
  include apache::module::authz_pam
  concat::fragment { "${pam_service}_pam_allow_${name}":
    target  => "/etc/httpd/conf.d/pam-${pam_service}-allow-users",
    content => "${user}\n",
    order   => '10';
  }
}
