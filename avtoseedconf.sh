#!/bin/sh

#
# avtoseedconf.sh -- avtomagic installation, preseed procedure for d-i
#  configure script
# author: Per Andersson
#

#
# Copyright © 2011 Per Andersson
#
# This file is part of avtoseed.
#
# avtoseed is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# avtoseed is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with avtoseed.  If not, see <http://www.gnu.org/licenses/>.
#


set -e

. /usr/share/debconf/confmodule


## possible variables and values
# avtoseed/machine   := default
# avtoseed/partition := default | manual
#
# default values avtoseed/machine=default avtoseed/partition=default
# this sets seedfiles to
#
#   packages-default.cfg
#   users-default.cfg
#   partition-default.cfg


# files to emit
seedfiles="PACKAGES USERS PARTITION"


# read variables from the kernel command line
for arg in $(cat /proc/cmdline | sed 's/^.* --\s*//'); do
    var=$(echo $arg | sed 's/=.*//')
    val=$(echo $arg | sed 's/.*=//')

    # replace placeholders with actual files
    case $var in
        "avtoseed/machine")
            # default file inclusion is for live machines
            seedfiles="$(echo $seedfiles| sed "s/PACKAGES/packages-$val.cfg/")"
            seedfiles="$(echo $seedfiles | sed "s/USERS/users-$val.cfg/")"
            ;;
        "avtoseed/partition")
            if [ "$val" = "manual" ]; then
                # partition manually, do not load any preseed file
                # with disk recipe
                seedfiles="$(echo $seedfiles | sed 's/PARTITION//')"
            else
                seedfiles="$(echo $seedfiles | sed "s/PARTITION/partition-$val.cfg/")"
            fi
            ;;
        *)
            ;;
    esac
done


## default values
# packages
seedfiles=$(echo $seedfiles | sed 's/PACKAGES/packages-default.cfg/')
# users
seedfiles=$(echo $seedfiles | sed 's/USERS/users-default.cfg/')
# partition
seedfiles=$(echo $seedfiles | sed 's/PARTITION/partition-default.cfg/')


# emit preseed files to include
db_set preseed/include "$seedfiles"
