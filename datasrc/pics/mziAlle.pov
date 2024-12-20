/*
    Copyright 2005,2006 by Mark Weyer
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

#declare Hintergrund = 1;
#declare Dreifachlicht = 1;
#declare Breite = 10;
#declare Hoehe = 4;

#include "cuyopov.inc"



#declare Radius = 4/5;

#macro Wurst(X1,X2,Y,c)
  sphere_sweep {
    linear_spline 2
    <X1,Y,0> Radius
    <X2,Y,0> Radius
    no_shadow
    Textur(texture{
      pigment {rgb c}
      finish {
        specular 1/5
        ambient 1/4
      }})
  }
#end


Wurst(-4,-4,1,<0,1,0>)
Wurst(-2,0,1,<0,1,0>)
Wurst(2,2,1,<1,0,0>)
Wurst(4,4,1,<0,0,0>)
Wurst(-4,-2,-1,<0,0,1>)
Wurst(1,3,-1,<0,0,1>)

