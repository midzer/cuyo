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

#ifndef(Eigene_Kamera)

  camera {
    orthographic
    location -100*z
    direction z
    right Breite*x
    up Hoehe*y
  }

#end



#ifdef(Nur_Umriss)

  #macro Textur(T)
    texture {pigment {rgb 1} finish {ambient 1}}
  #end

#else

  background {rgb Hintergrund}

  #ifdef(Dreifachlicht)
    light_source {<-1,1,-1>*10000 1 parallel point_at 0}
    light_source {<0,-1,-1>*10000 1/3 parallel point_at 0}
    light_source {<1,0,-1>*10000 1/3 parallel point_at 0}
  #else
    #ifndef(Eigenes_Licht)
      light_source {<-1,2,-3>*10000 1 parallel point_at 0}
    #end
  #end

  #macro Textur(T)
    texture{T}
  #end

#end

