SSLProtocol -all +SSLv3 +TLSv1
SSLCipherSuite HIGH:MEDIUM:!aNULL:!SSLv2:!MD5:@STRENGTH
SSLHonorCipherOrder on

# set STS Header
Header add Strict-Transport-Security "max-age=15768000"
