/*
    Copyright 2006,2008,2011,2014 by Mark Weyer

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

#include "dungeon.inc"

#declare Schweissnaht = 0.02;
#declare Dicke = 0.1;
#declare Stabdicke = 0.05;
#declare Rundung = 0.01;
#declare Dreh1 = 3;
#declare Dreh2 = 5;
#declare Seitenlaenge = sqrt(0.5)/cos((45-max(Dreh1,Dreh2))/180*pi);
#declare Seitengap = (1-Seitenlaenge)/2;
#declare Stabdz = 2*Rundung+Schweissnaht+Stabdicke/2;
#declare numStaebe = 4;
#declare Stabdx = Seitenlaenge/numStaebe;
#declare Krummheit = 0.1;
#declare Hoehe_ = BlockHoehe*10/11;

#declare Rost = function {pattern {bozo scale 1/13}}
#declare Kruemmung = function {pattern {bozo}}

#declare Stab = function (XX,YY,ZZ,D) {
  pow(mod(max(0,min(Seitenlaenge,XX-Seitengap
      +(Kruemmung(XX,YY,ZZ+D)-1/2)*(1-cos(YY*4*pi/Hoehe_))*Krummheit)),
    Stabdx)-Stabdx/2,2) +
  pow(max(0,YY-Hoehe_/2+Dicke/2,Dicke/2-YY),2) +
  pow(ZZ-Seitengap-Stabdz,2)
}

#macro Kaefig(D,E,Y) isosurface {
  function {-sqrt(
    pow(max(0,Schweissnaht+Rundung-sqrt(
        pow(max(0,Seitengap+Rundung-x,x-1+Seitengap+Rundung),2) +
        pow(max(0,Rundung-min(y+E,Hoehe_/2-y),
          min(y,Hoehe_/2-y)-Dicke+Rundung),2) +
        pow(max(0,Seitengap+Rundung-z,z-1+Seitengap+Rundung),2)
      )),2) +
    pow(max(0,Schweissnaht+Stabdicke/2-sqrt(
      min(Stab(x,y,z,D),Stab(1-z,y,x,D),
        Stab(1-x,y,1-z,D),Stab(z,y,1-x,D)))),2) +
    pow(max(0,Schweissnaht+Stabdicke/2-sqrt(
      pow(sqrt(
        pow(max(0,abs(x-1/2)-1/2+Seitengap+Stabdz),2) +
        pow(max(0,abs(z-1/2)-1/2+Seitengap+Stabdz),2))
        - Stabdicke,2) +
      pow(y-Hoehe_/8,2))),2)
  )}
  threshold -Schweissnaht
  contained_by {box {-0.1 <1.1,Hoehe_*0.6,1.1>}}
  max_gradient 1.1
  translate (Y)*y
  Textur(texture{
    function {max(Rost(x,y,z),Rost(1-z,y,x),Rost(1-x,y,1-z),Rost(z,y,1-x))}
    texture_map {
      [0.75 pigment {rgb <3,5,8>/26} finish {specular 0.8}]
      [0.75 pigment {rgb <5,2,1>/24}]
    }
  })
}
#end

#declare Block = union {
  object {Kaefig(40,0,Hoehe_/2) translate -1/2 rotate Dreh1*y translate 1/2}
  object {Kaefig(0,1/4,0) translate -1/2 rotate -Dreh2*y translate 1/2}
  translate 1/3*y
}

Setze()

