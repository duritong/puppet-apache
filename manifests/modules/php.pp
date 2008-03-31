# php/manifests/init.pp - various ways of installing php
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# changed and improved by immerda project group admin(at)immerda.ch
# See LICENSE for the full license granted to you.

class php::base {
    package{php:
        ensure => installed,
        before => Service[apache],
        notify => Service[apache],
    }
}

class php::centos inherits php::base {}

define php::debian::pear ($version = '') {
	include "php::debian::pear::common"

	package { "php${version}-${name}": ensure => installed }
}

class php::debian::pear::common {
	package { ["php-pear", "php5-common" ]: ensure => installed }
}

class php::debian inherits php::base {
    Package[php]{
        name => 'php5',
    }

	package { [ "php5", "php5-cli", "libapache2-mod-php5", "phpunit2" ]: 
        ensure => installed, 
        required => Package[php],
    }

	php::debian::pear { [
		"auth-pam", "curl", "idn", "imap", "json", "ldap", "mcrypt", "mhash",
		"ming", "mysql", "odbc", "pgsql", "ps", "pspell", "recode", "snmp",
		"sqlite", "sqlrelay", "tidy", "uuid", "xapian", "xmlrpc", "xsl"
		]:
			version => 5
	}

	include "php::debian::common"
}
# ubuntu might be the same as debian
class php::ubuntu inherits php::debian {}


class php::debian::common {
	php::pear {
		[ auth, benchmark, cache, cache-lite, date, db, file, fpdf, gettext,
		html-template-it, http, http-request, log, mail, mail-mime, net-checkip,
		net-dime, net-ftp, net-imap, net-ldap, net-sieve, net-smartirc, net-smtp,
		net-socket, net-url, pager, radius, simpletest, services-weather, soap,
		sqlite3, xajax, xml-parser, xml-serializer, xml-util ]:
	}
}

class php::gentoo inherits php::base {
    Package[php]{
        category => 'dev-lang',
    }
   
    # config files
    file{"/etc/php/apache2-php5/php.ini":
        source => [
	        "puppet://$server/dist/apache/php/apache2_php5_php.ini/${fqdn}/php.ini",
	        "puppet://$server/dist/apache/php/apache2_php5_php.ini/php.ini",
	        "puppet://$server/apache/php/apache2_php5_php.ini/php.ini"
	    ],
	    owner => root,
	    group => 0,
	    mode => 0644,
	    require => [ Package[php], Package[apache] ],
	    notify => Service[apache],
    }
}



