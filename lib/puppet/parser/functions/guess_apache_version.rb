# Try to guess the version of apache to be installed.
# Certain apache modules depend on each other, so we
# need to evaluate the apache version before it gets
# installed. This function decides which apache version
# is going to be installed based on the `operatingsystemrelease`
# fact.
module Puppet::Parser::Functions
  newfunction(:guess_apache_version, :type => :rvalue) do |args|
    release = lookupvar('operatingsystemrelease')
    unknown = 'unknown'

    case lookupvar('operatingsystem')
      when 'CentOS'
        if release.to_i > 6
          version = '2.4'
        else
          version = '2.2'
        end

      when 'Debian'
        if release.to_i > 7
          version = '2.4'
        elsif release.to_i == 7
          version = '2.2'
        else
          version = unknown
        end

      when 'Ubuntu'
        case release
          when /(12.04|12.10|13.04|13.10)/
            version = '2.2'
          when /(14.04|14.10|15.04|15.10|16.04)/
            version = '2.4'
          else
            version = unknown
        end

      else
        version = unknown
    end
    version
  end
end
