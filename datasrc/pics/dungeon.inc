/*
    Copyright 2006,2008,2010,2011,2014 by Mark Weyer

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

#declare Eigenes_Licht = 1;
#declare Eigene_Kamera = 1;

#declare Typ_FirstPerson = 1;
#declare Typ_Draufsicht = 2;
#declare Typ_Seitensicht = 3;
#declare Typ_Sonst = 4;

#ifdef (Version)
  #declare Typ=Typ_FirstPerson;
#else
  #ifdef (DraufVersion)
    #declare Typ=Typ_Draufsicht;
  #else
    #ifdef (SeitenVersion)
      #declare Typ=Typ_Seitensicht;
    #else
      #declare Typ=Typ_Sonst;
    #end
  #end
#end

#if (Typ=Typ_FirstPerson)

  #declare Nebel = 1;

#else
  #if (Typ=Typ_Draufsicht)

    #declare Breite = 2;
    #ifdef (Spezial_Halbhoch)
      #declare Hoehe = 2;
      #declare BodenHoehe = 4;
    #else
      #declare Hoehe = 4;
    #end
    #declare BlockDrehung = DraufVersion;
    #declare Nebel = 1;

  #else
    #if (Typ=Typ_Seitensicht)

      #declare Breite = 2;
      #declare Hoehe = 2;
      #declare BlockDrehung = SeitenVersion-3;
      #declare Nebel = 0;

    #end
  #end
#end

#ifdef (Hoehe)
  #ifndef (BodenHoehe)
    #if (Typ!=Typ_Sonst)
      #declare BodenHoehe=Hoehe;
    #end
  #end
#end

#include "dungeon_boden.inc"

#declare Hintergrund = 0;
#declare Nebelweite = 1000;

#include "cuyopov.inc"

#declare BlockHoehe = 3;
#declare Ueberlappung = 0.03;
#declare Augenhoehe = BlockHoehe*2/3;
#declare Sichtweite = 5.5;
 
#declare Groesse = array[7] {   // Die letzten zwei Einträge
                                // sind Dummies für Boden und Himmel
  4,4,3,3,2,0,-1
};

#macro BlockAusWand(Wand)
  union {
    object {Wand}
    object {Wand rotate 90*y translate z}
    object {Wand rotate 180*y translate x+z}
    object {Wand rotate 270*y translate x}
  }
#end

#macro SetzBlock(X,Z)
  object {Block clipped_by
    {box {<-1,-1,-1> <2,1+BlockHoehe,2>}} translate <X,0,Z>}
#end

#macro Setze()
  #if (Typ=Typ_FirstPerson)

    #local Z=int(sqrt(Version+1));
    #local X=Version+1-Z*Z-Z;
    SetzBlock(X,Z)
    #ifndef (Nur_Umriss)
      object {Boden}
    #end

  #else

    union {
      #ifndef (Nur_Umriss)
        #if (Typ=Typ_Draufsicht)
          object {Boden}
        #end
      #end

      #ifdef (Spezial_Einzel)
        object {
          SetzBlock(-1,0)
	  #if (Typ=Typ_Draufsicht)
            #if ((DraufVersion=1) | (DraufVersion=3))
              translate x
            #end
            #if (DraufVersion>=2)
              translate -z
            #end
          #else
            translate x/2
          #end
        }
      #else
        #ifdef (Spezial_Halbhoch)
          object {
            DoppelBlock
            translate <1,0,-3>
            #if ((DraufVersion=1) | (DraufVersion=3))
              translate -2*x
            #end
            #if (DraufVersion>=2)
              translate 2*z
            #end
            #if (DraufVersion=4)
              translate 2*z
            #end
            #if (DraufVersion=5)
              translate -4*z
            #end
          }
        #else
          union {
            SetzBlock(-1,0) SetzBlock(-1,-1)
            rotate BlockDrehung*90*y
          }
        #end
      #end
    }

  #end
#end


#ifndef (Nur_Umriss)

  #if (Typ!=Typ_Sonst)
    #if (Nebel)
      box{
        -Nebelweite <Nebelweite,BlockHoehe,Nebelweite>
        hollow
        pigment {rgbt <0,0,0,1>}
        interior {media {emission 1/Sichtweite}}
      }
    #end
  #end

  #declare Numlights = 4*5;

  #local I=0;
  #while (I<Numlights)
    light_source {
      y*10000
      #if (Typ=Typ_Seitensicht)
        13/Numlights
      #else
        4/Numlights
      #end
      parallel
      point_at 0
      rotate 45*z
      rotate 360*I/Numlights*y
    }
    #local I=I+1;
  #end

#end


#if (Typ=Typ_FirstPerson)

  camera {
    location <1/2,Augenhoehe,1/2>
    right 2*x
    #switch (Groesse[int(sqrt(Version+1))-1])
      #case (4) #local hoch=1; #local runter=1; #break
      #case (3) #local hoch=1/2; #local runter=1; #break
      #case (2) #local hoch=1/2; #local runter=1/2; #break
      #case (0) #local hoch=0; #local runter=1; #break
      #case (-1) #local hoch=1; #local runter=0; #break
    #end
    up (hoch+runter)*y
    direction (hoch-runter)/2*y+z
  }

#else
  #if (Typ=Typ_Draufsicht)

    #declare DZDY = 1/2;

    #ifdef (Spezial_Halbhoch)
      #declare DZ = -2;
    #else
      #declare DZ = -1;
    #end

    camera {
      orthographic
      location <0,BlockHoehe,DZ>+<0,1,-DZDY>*10
      direction <0,-1,DZDY>
      right Breite*x
      up Hoehe*z
    }

  #else
    #if (Typ=Typ_Seitensicht)

      #ifdef (Spezial_Einzel)
        #declare Scale = 1.5;
      #else
        #declare Scale = 2/BlockHoehe;
      #end

      camera {
        orthographic
        location <(1-BlockDrehung)*(1-Scale)*0.5, Hoehe/2/Scale, -100>
        direction z
        right Breite/Scale*x
        up Hoehe/Scale*y
      }

    #end
  #end
#end

