#
# apache module
#
# Copyright 2008, admin(at)immerda.ch
# Copyright 2008, Puzzle ITC GmbH
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#

# Global variables:
#
# $apache_default_user: Set this to the user with which the
#                       apache is running.
# $apache_default_group: Set this to the group with which the
#                        apache is running.
class apache {
  case $operatingsystem {
    centos: { include apache::centos }
    gentoo: { include apache::gentoo }
    debian: { include apache::debian }
    ubuntu: { include apache::ubuntu }
    openbsd: { include apache::openbsd }
    default: { include apache::base }
  }
  if $use_munin {
    include apache::status
  }
  if $use_shorewall {
    include shorewall::rules::http
  }
}

