/*
    Copyright 2007 by Mark Weyer
    Maintenance modifications 2010,2011 by the cuyo developers

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


#declare Breite = 2;
#declare Hoehe = 2;

#include "aehnlich.inc"


#declare DoppelEbene = function(X,Y,Z,Phi,Psi,D) {
  pow(max(0,abs(
      X*sin(Phi*pi/180)*cos(Psi*pi/180) +
      Y*sin(Phi*pi/180)*sin(Psi*pi/180) +
      Z*cos(Phi*pi/180))
    -D+Rundheit),2)
}

#declare Stab = function(X,Y,Z) {
  pow(max(0,2*Rundheit-sqrt(
    DoppelEbene(X,Y,Z,0,0,DStab) +
    DoppelEbene(X,Y,Z,60,0,DStab) +
    DoppelEbene(X,Y,Z,-60,0,DStab) +
    DoppelEbene(X,Y,Z,90,90,1/2))),2)
}

#declare Achteck = function(X,Y,Z) {
  pow(max(0,2*Rundheit-sqrt(
    #local I=0;
    #while (I<350)
      DoppelEbene(X,Y,Z-ZAchteck,60,I,DAchteck) +
      #local I=I+45;
    #end
    DoppelEbene(X,Y,Z+DDAchteck/2,0,0,DDAchteck/2))),2)
}

isosurface {
  function {
    Rundheit-sqrt(
      Stab(mod(x+2,1)-1/2,-y,z) +
      Stab(mod(y+2,1)-1/2,x,z) +
      Achteck(mod(x+2,1)-1/2,mod(y+2,1)-1/2,z))
  }
  max_gradient 1.6
  contained_by {box {<-2,-2,-1/2> <2,2,1/2>}}
  Textur(Fassung)
}

