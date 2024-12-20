/*
    Copyright 2006,2011,2014 by Mark Weyer

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

#ifndef(Version)
  #declare Breite=4;
  #declare Hoehe=4;
#end

#include "dungeon.inc"



#declare textur = pigment {rgb <0.9,1,0.7>*2/3}

#declare Wanddicke = 0.1;
#declare Plastikdicke = Wanddicke/3;;
#declare Lochdicke = 0.03;
#declare Lochdicke_ = sqrt(2)*Lochdicke;
#declare Leiterbahnenabstand = 0.02;
#declare Keinschlitz = 2*Ueberlappung;

#declare Eckenrundung = union {
  cylinder {<Wanddicke,0,0> <Wanddicke,BlockHoehe,0> Ueberlappung}
  sphere {<Wanddicke,BlockHoehe,0> Ueberlappung}
  cylinder {<Wanddicke,BlockHoehe,0> <Wanddicke,BlockHoehe,Wanddicke> Ueberlappung}
}

#declare Ecke = union {
  box {
    <-Ueberlappung,0,0>
    <Wanddicke+Ueberlappung,BlockHoehe,Wanddicke>
  }
  box {
    <0,0,0>
    <Wanddicke,BlockHoehe+Ueberlappung,Wanddicke>
  }
  box {
    <0,0,-Ueberlappung>
    <Wanddicke,BlockHoehe,Wanddicke+Ueberlappung>
  }
  object {Eckenrundung}
  object {Eckenrundung rotate 90*y translate <0,0,Wanddicke>}
  object {Eckenrundung rotate 180*y translate <Wanddicke,0,Wanddicke>}
  object {Eckenrundung rotate 270*y translate <Wanddicke,0,0>}
  Textur(textur)
}

#declare Schlitz = function(x0,y0,x1,y1,xx,yy,dm) {
  sqrt((
    pow(dm,2)+
    pow(max(2*(x0-xx)+dm,2*(y0-yy)-dm,2*(xx-x1)-dm,2*(yy-y1)+dm,0),2)
  )/2)
}

#declare fRandom = function {pattern {bozo scale 3}}

#declare Platine = function(xx,yy,xm,ym) {
  min(
    pow(ym,2)+pow(select(fRandom(xx-xm,yy-ym,0)-0.49,
      xm,
      min(xm,1-xm,0)),2),
    pow(xm,2)+pow(select(fRandom(xx-xm,yy-ym,0)-0.51,
      min(ym,1-ym,0),
      ym),2))
}

#declare Wand = union {
  object {Ecke}
  object {Ecke translate (1-Wanddicke)*x}
  box {  // Platine
    <0,0,Wanddicke/2> <1,BlockHoehe-Plastikdicke/2,Wanddicke*2/3>
    Textur(pigment {
      function {
        min(
          Platine(x,y, mod(x,1)-1/2, mod(y,1)-1/2),
          Platine(x,y, mod(x,1)+1/2, mod(y,1)-1/2),
          Platine(x,y, mod(x,1)-1/2, mod(y,1)+1/2))
      }
      colour_map {[0.0625 rgb 1/3] [0.0625 rgb <0,1/3,0>]}
      scale Leiterbahnenabstand
    })
  }
  union {
    isosurface {
      function {min(Plastikdicke,sqrt(pow(z-Plastikdicke/2,2)
        +pow(max(0,Plastikdicke/2+Lochdicke/2
          -Schlitz(
            Keinschlitz,BlockHoehe/2,
            1/2-Wanddicke-Ueberlappung-Keinschlitz,BlockHoehe-1/8,
            mod(x-Wanddicke-Ueberlappung,1/2-Wanddicke-Ueberlappung),y,
            mod(mod(x,1/2)-y+1001*Lochdicke_,2*Lochdicke_)
              -Lochdicke)
        ),2)))
      }
      threshold Plastikdicke/2
      contained_by {box {
        <0,0,-Plastikdicke/2>
        <1,BlockHoehe-Plastikdicke/2,Plastikdicke*3/2>
      }}
      max_gradient 1.1
    }
    box {<0,0,Wanddicke-Plastikdicke> <1,BlockHoehe-Plastikdicke/2,Wanddicke>}
    box {
      <0,BlockHoehe-Plastikdicke,Plastikdicke/2>
      <1,BlockHoehe,Wanddicke-Plastikdicke/2>
    }
    cylinder {
      <0,BlockHoehe-Plastikdicke/2,Plastikdicke/2>
      <1,BlockHoehe-Plastikdicke/2,Plastikdicke/2> Plastikdicke/2
    }
    cylinder {
      <0,BlockHoehe-Plastikdicke/2,Wanddicke-Plastikdicke/2>
      <1,BlockHoehe-Plastikdicke/2,Wanddicke-Plastikdicke/2> Plastikdicke/2
    }
    Textur(textur)
  }
}

#declare Langwand = union {
  object{Wand translate -2*x}
  object{Wand translate -x}
  object{Wand}
  object{Wand translate x}
  object{Ecke translate 2*z}
  translate -2*z
}

#declare Block = BlockAusWand(Wand)

#declare DoppelBlock =
  union {
    object {Langwand}
    object {Langwand rotate 90*y}
    object {Langwand rotate 180*y}
    object {Langwand rotate 270*y}
    box {<-2,BlockHoehe-3/100,-2>+1/100 <2,BlockHoehe,2>-1/100 pigment {rgb 0}}
  }

Setze()

