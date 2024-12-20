/*
    Copyright 2007 by Mark Weyer

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


#declare Dreifachlicht = 1;
#declare Hintergrund = 0;

#include "cuyopov.inc"

#declare KugelRad = 1/4;
#declare Rundheit = 1/20;
#declare DStab = 1/5;
#declare DDAchteck = 1/4;
#declare ZAchteck = 2;
#declare BAchteck = KugelRad + Rundheit + 1/32*sqrt(2);
#declare DAchteck = BAchteck*sqrt(3/4) + (DDAchteck+ZAchteck)/2;

#declare Finish = finish {
  ambient 0
  specular 1/2
}

#declare Fassung = texture{
  pigment {rgb 2/3}
  finish {Finish}
}

