# determine the version of apache installed
Facter.add('apache_version') do
  confine :osfamily => ['Debian','RedHat']
  def apache_exec
    @apache_exec ||= ['/usr/sbin/httpd','/usr/sbin/apache2'].find{|e| File.exists?(e) }
  end
  confine do
    apache_exec
  end
  setcode do
    if (s = Facter::Util::Resolution.exec("#{apache_exec} -v")) && \
      (vl = s.split("\n").find{|l| l =~ /^Server version: Apache/ })
      if m = vl.match(/^Server version: Apache\/([\d\.]+)/)
         m[1]
      end
    end
  end
end
