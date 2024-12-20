#
#   Copyright 2005-2007 by Mark Weyer
#   Maintenance modifications 2010,2011 by the cuyo developers
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

#
# Usage
# =====
#
# If you don't want to know too much:
#
# make all
# make install
#
# A more thorough description follows.
#
#
#
# Interface:
# ==========
#
# make all
#   Create all pictures that have sources
#
# make <levelname>
#   Create all pictures from an individual level that have sources
#   This is only a rule of thumb. For example, the pictures for all
#   kacheln?.ld levels are created by "make kacheln".
#
# make install
#   Copy all pictures that were created to their destination.
#   In addition, xpm pictures are compressed
#
# make tidy
#   Delete all intermediate files and all files ending in ~.
#
# make clean
#   Delete all files that were regularly created.
#
#
# Requirements:
# =============
#
# You will need make, netpbm (version >= 10.3),
# ocaml (including the native-code compilers), and povray.
#




DATA_DIR = ../../data

INSTALL_DIR = $(DATA_DIR)/pics




make.ml: ../make.ml
	cp ../make.ml .

make.mli: ../make.mli
	cp ../make.mli .

Makefile.common: ../Makefile.common
	cp ../Makefile.common .



cvsfiles_local:
	echo "colors.mgk" >> cvsfiles
	echo "titel-orig.png" >> cvsfiles
	echo "TODO" >> cvsfiles

distfiles_local: makefile.opt
	$(MAKE) -C $(DATA_DIR) used_images
	./makefile.opt dist `cat $(DATA_DIR)/used_images` >> distfiles
	echo "colors.mgk" >> distfiles

cleanfiles_local:
	echo "make.ml" >> cleanfiles
	echo "make.mli" >> cleanfiles
	echo "Makefile.common" >> cleanfiles



include Makefile.common



# The following targets are listed here to prevent them being handed to
# makefile.opt although we do not have real rules for them:

../Makefile.common:
	$(NOOP)

