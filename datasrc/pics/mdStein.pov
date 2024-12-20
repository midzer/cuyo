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

#declare Reihen = 7;
#declare Rauhheit = 0.015;
#declare Rundung = 0.04;
//#declare Rauhscale = 1;
#declare Rauhscale = 1/10;
#declare Hoehe_ = BlockHoehe*12/13;

//#declare RauhF = function {pattern {agate scale Rauhscale}}
#declare RauhF = function {pattern {bozo scale Rauhscale}}

#declare RS = seed(1234);

#macro Quader(x0,y0,z0,x1,y1,z1,D)
  isosurface {
    function {
      sqrt(
        pow(max(0,x-x1+Rundung,x0-x+Rundung),2) +
        pow(max(0,y-y1+Rundung,y0-y+Rundung),2) +
        pow(max(0,z-z1+Rundung,z0-z+Rundung),2)) -Rundung
      + (2*RauhF(x+D,y,z)-1)*Rauhheit
    }
    threshold 0
    contained_by {box{<x0,y0,z0>-Rauhheit <x1,y1,z1>+Rauhheit}}
    max_gradient 1.1*(1+2*Rauhheit/Rauhscale)
    Textur(pigment {
      granite
      #local Helligkeit=1/2;
      colour_map {
        [0.35 rgb <0.5,0.5,0.55>*Helligkeit]
        [0.4 rgb <0.5,0.4,0.3>*Helligkeit]
        [0.45 rgb <0.5,0.53,0.5>*Helligkeit]
        [0.7 rgb <0.5,0.53,0.5>*Helligkeit]
        [0.7 rgb <0.54,0.5,0.5>*Helligkeit]
      }
      scale <7,7,1>/3
      rotate acos(rand(RS))/pi*180*x
      rotate rand(RS)*360*z
      translate D*y
    })
  }
#end

#declare Wand = union {
  #local I = 0;
  #while (I<Reihen)
    Quader(
      mod(I,2)*1.1/3,I*Hoehe_/Reihen,0,
      1-mod(I+1,2)*1.1/3,(I+1)*Hoehe_/Reihen,1/3,
      10*I)
    #local I=I+1;
  #end
}

#declare Block = union {
  BlockAusWand(Wand)
  Quader(1/3,0,1/3,2/3,Hoehe_,2/3,-10)
}

Setze()

