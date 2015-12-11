# determine the version of apache installed
 
def parse_version(version_string)
  version = ""
  version_string.each_line do |line|
    if line.match(/^Server version/)
      version = line.scan(/Apache\/(.*) /)[0][0]
    end
  end
  return version
end
 
Facter.add('apache_version') do
  setcode do
    case Facter.value('osfamily')
    when /RedHat/
      if File.exists?('/usr/sbin/httpd')
        version = parse_version(%x(/usr/sbin/httpd -v))
      end
    when /Debian/
      if File.exists?('/usr/sbin/apache2')
        version = parse_version(%x(/usr/sbin/apache2 -v))
      end
    else
      version = 'undef'
    end
  end
end
