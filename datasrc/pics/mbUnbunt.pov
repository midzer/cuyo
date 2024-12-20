/*
    Copyright 2005 by Mark Weyer

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

#declare Breite1 = 2;
#declare Hoehe1 = 0;
#declare Breite0 = 2;
#declare Hoehe0 = 2;

#include "bunt.inc"


#local I=0;
#while (I<Farben)
  object {
    Bunt(I,I,2)
    translate (2*I-Farben)*x
  }
  #local I=I+1;
#end

sphere {
  Farben*x Rad_klein
  no_shadow
  Textur(texture {
    pigment {rgb 1/2}
    finish {specular 1/3 ambient 1/3}
  })
}

