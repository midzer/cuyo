/*
    Copyright 2005 by Mark Weyer
    Maintenance modifications 2006,2011 by the cuyo developers

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

#declare Breite = 6;
#declare Hoehe = 18;

#include "zahn.inc"

#ifdef (Gras)
  #declare Haut_Farbe = <1/2,1/2,1>;
#end

#macro Gebissreihe(V,D)
  union {
    object {Gebiss(0,V,D,D)  translate -2*x}
    object {Gebiss(1,V,D,D)}
    object {Gebiss(2,V,D,D)  translate 2*x}
  }
#end

#macro Gebissfeld(D)
  union {
    object {Gebissreihe(0,D)  translate 2*y}
    object {Gebissreihe(1,D)}
    object {Gebissreihe(2,D)  translate -2*y}
  }
#end

union {
  object {Gebissfeld(0)  translate 6*y}
  object {Gebissfeld(1)}
  object {Gebissfeld(2)  translate -6*y}
}

