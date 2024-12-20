/*
    Copyright 2008,2011 by Mark Weyer

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#declare Version = 49;

#include "dungeon.inc"

union {
  sphere {
    0 1/2
    hollow
    pigment {
      gradient x
      colour_map {
        [0 rgb z]
        [1 rgb <0,1/2,1>]
      }
      translate -x/2
    }
    finish {ambient 1}
    scale 1000
  }

  rotate 90*HimmelVersion*y
}

