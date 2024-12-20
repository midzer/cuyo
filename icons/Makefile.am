#
#   Copyright 2007 by the cuyo developers
#   Maintenance modifications 2008,2011,2012 by the cuyo developers
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

desktopdir = $(datarootdir)/applications
desktop_DATA = cuyo.desktop


# The following would automatically put cuyo with the full
# path into the desktop file. But do we really want that?
# Maybe things are easier without full path.
# (Then the user can move the binary around without having to
# worry about the desktop file.)   -Immi

#cuyo.desktop: cuyo.desktop.in
#	cp cuyo.desktop.in cuyo.desktop
#	echo "Exec=$(bindir)/cuyo" >> cuyo.desktop


iconsdir = $(datarootdir)/icons/hicolor
nobase_icons_DATA = 32x32/apps/cuyo.png 64x64/apps/cuyo.png

EXTRA_DIST = $(nobase_icons_DATA) cuyo.desktop

MAINTAINERCLEANFILES = Makefile.in

