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

# manage a simple apache
class apache(
  $cluster_node = '',
  $manage_shorewall = false,
  $manage_munin = false
) {
  case $::operatingsystem {
    centos: { include apache::centos }
    gentoo: { include apache::gentoo }
    debian,ubuntu: { include apache::debian }
    openbsd: { include apache::openbsd }
    default: { include apache::base }
  }
  if $apache::manage_munin {
    include apache::status
  }
  if $apache::manage_shorewall {
    include shorewall::rules::http
  }
}

