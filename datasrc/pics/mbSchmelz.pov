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

#declare Breite1 = 2;
#declare Hoehe1 = 4;
#declare Breite0 = 0;
#declare Hoehe0 = 0;

#include "bunt.inc"

#declare Schritte = 4;
#declare Schmelzabstand = 2*(1-Schritt/(Schritte+1));

#local I=0;
#while (I<Farben)
  #local J=0;
  #while (J<Farben)
    object {
      Bunt(I,J,Schmelzabstand)
      translate <2*I+1-Farben,2*Farben-4*J-3,0>
    }
    #local J=J+1;
  #end
  #local I=I+1;
#end


