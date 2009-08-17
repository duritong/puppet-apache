# Redirect VHost to redirect hosts
# Parameters:
# - ensure: wether this vhost is `present` or `absent`
# - domain: the domain to redirect (*name*)
# - domainalias: A list of whitespace seperated domains to redirect
# - target_url: the url to redirect to. Note: We don't want http://example.com/foobar only example.com/foobar
# - server_admin: the email that is shown as responsible
# - ssl_mode: wether this vhost supports ssl or not
#   - false: don't enable ssl for this vhost (default)
#   - true: enable ssl for this vhost
#   - force: enable ssl and redirect non-ssl to ssl
#   - only: enable ssl only
# - vhost_destination: where to put the vhost
define apache::vhost::redirect(
    $ensure = present,
    $domain = 'absent',
    $domainalias = 'absent',
    $target_url,
    $server_admin = 'absent',
    $ssl_mode = false,
    $vhost_destination = 'absent'
){
    # create vhost configuration file
    # we use the options field as the target_url
    ::apache::vhost::template{$name:
        ensure => $ensure,
        template_mode => 'redirect',
        domain => $domain,
        domainalias => $domainalias,
        server_admin => $server_admin,
        allow_override => $allow_override,
        options => $target_url,
        ssl_mode => $ssl_mode,
    	vhost_destination => $vhost_destination,
    }
}

