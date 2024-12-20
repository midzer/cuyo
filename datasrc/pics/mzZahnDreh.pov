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

#declare Breite = 8;
#declare Hoehe = 16;

#include "zahn.inc"



#macro Gebiss_Teilreihe(V,H_,V_,D)
  union {
    object {Gebiss(0,V_,V,H_)  rotate D*z  translate -x}
    object {Gebiss(1,V_,V,H_)  rotate D*z  translate x}
  }
#end

#macro Gebiss_Reihe(H_,V_,D)
  union {
    object {Gebiss_Teilreihe(0,H_,V_,D)  translate -2*x}
    object {Gebiss_Teilreihe(1,H_,V_,D)  translate 2*x}
  }
#end

#macro Gebiss_Teilfeld(V_,D)
  union {
    object {Gebiss_Reihe(0,V_,D)  translate y}
    object {Gebiss_Reihe(1,V_,D)  translate -y}
  }
#end

#macro Gebiss_Feld(D)
  union {
    object {Gebiss_Teilfeld(0,D)  translate 2*y}
    object {Gebiss_Teilfeld(1,D)  translate -2*y}
  }
#end

union {
  object {Gebiss_Feld(60)  translate 4*y}
  object {Gebiss_Feld(30)  translate -4*y}
}


