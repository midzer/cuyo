#! /bin/sh

#
#   Copyright 2007 by the cuyo developers
#   Maintenance modifications 2007,2011 by the cuyo developers
#   Based on used_images.sh which, at that time, was
#     Copyright <=2002 by the cuyo developers
#     Modified 2007 by Mark Weyer
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

# Gibt alle Namen von Dateien aus, in im
# Verzeichnis $1/sounds liegen und in einer der Dateien
# aus $2 erwähnt werden.
# Gibt außerdem ein paar Systemsounds aus.
# Beispiel: used_sounds cuyo/sounds "summary.ld bla.ld"

cd $1/sounds

for i in *.wav *.it
do 
   if test `cd ..;cat $2 | grep -c $i` != 0
     then echo $1/sounds/$i
     else echo "Not included:" $1/sounds/$i >&2
   fi
done

