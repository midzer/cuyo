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

#declare Spezial_Halbhoch = 1;

#ifdef(BodenVersion)
  #declare Version = 36;
  #declare Gross=(BodenVersion=-1);
#else
  #declare Gross=0;
  #declare Breite=2;
  #declare Hoehe=2;
  #declare BodenHoehe=2;
#end

#if (Gross)

  camera {location -2*z right x up y direction z}

  light_source {<-1,1,-2>*1000 4}

  #include "dungeon_boden.inc"

  #switch (BodenPflanze)
    #case (1)
      object {Einheit translate -x rotate -45*x translate -y*2/3}
    #break
    #case (2)
      object {Beet translate -x/2 rotate -45*x scale 2 translate -y*2/3}
    #break
    #case (3)
      #local I=-1;
      #while (I<=1)
        object {Grashalm() scale 3 translate <I,-1,0>}
        #local I=I+1/6;
      #end
    #break
    #case (4)
      object {BlumeBlau() scale 3 translate <-2/3,-1,-1/3> rotate -90*x}
      object {BlumeBlau() scale 3 translate <-1/3,-1,0>}
      object {BlumeBlau() scale 3 translate <1/3,-1,-1/3> rotate -90*x}
      object {BlumeBlau() scale 3 translate <2/3,-1,0>}
    #break
    #case (5)
      object {BlumeRot() scale 3 translate <-2/3,-1,-1/3> rotate -90*x}
      object {BlumeRot() scale 3 translate <-1/3,-1,0>}
      object {BlumeRot() scale 3 translate <1/3,-1,-1/3> rotate -90*x}
      object {BlumeRot() scale 3 translate <2/3,-1,0>}
    #break
  #end

#else

  #declare DraufVersion = 0;

  #include "dungeon.inc"

  #ifdef(BodenVersion)

    object {
      Boden
      #if (mod(BodenVersion,2)>1/2)
        translate -x
      #end
      #if (mod(BodenVersion,4)>3/2)
        translate -z
      #end
      translate -1/2
      #if (mod(BodenVersion,8)>7/2)
        rotate 180*y
      #end
      #if (BodenVersion>15/2)
        rotate 90*y
      #end
      translate 1/2
    }

  #else

    object {Boden}

  #end

#end

