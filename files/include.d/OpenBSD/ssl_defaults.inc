SSLEngine on
#SSLCipherSuite HIGH:MEDIUM:!ADH:-SSLv2
SSLCipherSuite HIGH:MEDIUM:!aNULL:!SSLv2:!MD5:@STRENGTH
SSLCertificateFile    /etc/ssl/server.crt
SSLCertificateKeyFile /etc/ssl/private/server.key
