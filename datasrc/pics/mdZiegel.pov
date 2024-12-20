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


#declare xZiegel = 2;
#declare yZiegel = 10;
#declare gapZiegel = 0.04;
#declare Hoehe_ = BlockHoehe*22/23;

#declare Poren = function {pattern {crackle form x}}

#macro Schaum(x0,y0,z0,x1,y1,z1,PorenD,PorenR,D,R)
  isosurface {
    function {max(
      (PorenR-Poren(D+x/PorenD,y/PorenD,z/PorenD))*PorenD,
      sqrt(pow(max(0,x-x1+R,x0-x+R),2)
          +pow(max(0,y-y1+R,y0-y+R),2)
          +pow(max(0,z-z1+R,z0-z+R),2)
        )-R-1e-3)
    }
    threshold 0
    contained_by {box {<x0,y0,z0> <x1,y1,z1>}}
    max_gradient 1.1
  }
#end

#declare RS = seed(123);

#macro Ziegel(x0,y0,z0,x1,y1,z1)
  object {
    Schaum(
      x0+gapZiegel/2,y0+gapZiegel/2,z0+gapZiegel/2,
      x1-gapZiegel/2,y1-gapZiegel/2,z1-gapZiegel/2,
      0.01, 0.25, 0, gapZiegel/4)
    Textur(pigment {rgb <
      4/9+pow(rand(RS),2)/8,
      1/7+pow(rand(RS),2)/12,
      1/7+pow(rand(RS),2)/15>*4/5})
  }
#end

#declare Wand = union {
  #local I = 0;
  #while (I<yZiegel)
    #local J = 0;
    #while (J<xZiegel)
      Ziegel(
        (2*J+mod(I,2))/(2*xZiegel+1),Hoehe_*I/yZiegel,0,
        (2*J+2+mod(I,2))/(2*xZiegel+1),Hoehe_*(I+1)/yZiegel,1/(2*xZiegel+1))
      #local J = J+1;
    #end
    #local I = I+1;
  #end
}

#declare Block = union {
  BlockAusWand(Wand)
  Ziegel(1/(2*xZiegel+1),Hoehe_/2,1/(2*xZiegel+1),
    1-1/(2*xZiegel+1),Hoehe_,1/2)
  Ziegel(1/(2*xZiegel+1),Hoehe_/2,1/2,
    1-1/(2*xZiegel+1),Hoehe_,1-1/(2*xZiegel+1))
  object {
    Schaum(
      gapZiegel,gapZiegel,gapZiegel,
      1-gapZiegel,Hoehe_-gapZiegel,1-gapZiegel,
      0.03, 0.35, 10, 0)
    Textur(pigment {rgb 1/2})
  }
}

Setze()

