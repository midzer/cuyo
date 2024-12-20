#! /bin/sh

#
#   Copyright <=2002 by the cuyo developers
#   Maintenance modifications 2006-2008,2011 by the cuyo developers
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

if test ! -e ChangeLog ; then
       touch ChangeLog
fi

aclocal -I .
autoheader
automake -a -c --foreign
#if test ! -e config.guess ; then
#       cp /usr/share/automake/config.guess .
#fi
#if test ! -e config.sub ; then
#       cp /usr/share/automake/config.sub .
#fi
autoconf
echo
echo "Now you probably want to run"
echo "  ./configure"
echo "or"
echo "  ./configure --enable-maintainer-mode"
echo "or"
echo "  ./configure --enable-maintainer-mode --enable-datasrc-maintainer-mode"
echo "or"
echo "  ./configure --datadir=`pwd`/data"
echo "or something like this. (See README and README.maintainer)"

