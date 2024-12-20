/*
    Copyright 2005,2006 by Mark Weyer
    Maintenance modifications 2011 by the cuyo developers

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

#declare Farben=16;

#if (mod(Farben,2)=0)
  #declare Spalten=Farben+1;
  #declare Zeilen=Farben/2;
#else
  #declare Spalten=Farben;
  #declare Zeilen=(Farben+1)/2;
#end

#declare Breite1=0;
#declare Hoehe1=0;
#declare Breite0=2*Spalten;
#declare Hoehe0=2*Zeilen;


#include "bunt.inc"


#local I=0;
#while (I<Farben)
  #local J=0;
  #while (J<=I)
    #local N=I*(I+1)/2+J;
    object {
      Bunt(I,J,0)
      translate <2*mod(N,Spalten)+1-Spalten,Zeilen-2*div(N,Spalten)-1,0>
    }
    #local J=J+1;
  #end
  #local I=I+1;
#end


