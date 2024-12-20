/*
    Copyright 2006,2008,2011,2014 by Mark Weyer
    Maintenance modifications 2007,2011 by the cuyo developers

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

#include "mdGold.inc"

#declare Spezial_Einzel = 1;

#declare Gold = texture {
  pigment {rgb <1,2/3,0>/4}
  finish {specular 0.8 metallic}
}

/*
//Dekommentieren, wenn man die Stapel schnell anpassen will
#macro Muenze()
  cylinder {
    -HDicke*y HDicke*y Rad
    Textur(texture {Gold})
  }
#end
*/

#declare KopfRad = Rad*0.7;
#declare Rundheit = Rad/20;
#declare Gravurtiefe = KopfRad/64/sqrt(2); // Damit die Steigung immer 1 ist
#declare Rand = Rad/8;
#declare ZahlHoehe = Rad/3;
#declare ZifferBreite = Rad/5;
#declare ZifferRad = Rad/15;
#declare ZahlZMax = -Rad/3;
#declare ZahlZMin = ZahlZMax-ZahlHoehe;
#declare ZahlZMitte = (ZahlZMax+ZahlZMin)/2;
#declare ZahlKreisZ1 = ZahlZMax-ZifferBreite/2;
#declare ZahlKreisZ2 = ZahlZMin+ZifferBreite/2;
#declare ZahlLinienHoehe = ZahlHoehe-ZifferBreite+2*ZifferRad;
#declare ZweiD1 = sqrt(pow(ZifferRad,2)
  + pow(ZahlHoehe-ZifferBreite+ZifferRad,2));
#declare ZweiWinkel = atan((ZahlHoehe-ZifferBreite+ZifferRad)/ZifferRad)
  - asin(ZifferRad/ZweiD1);
#declare ZweiCos = cos(ZweiWinkel);
#declare ZweiSin = sin(ZweiWinkel);
#declare LogoRad1 = Rad/5;
#declare LogoRad2 = LogoRad1*2;
#declare LogoExtra = LogoRad1/2;
#declare LogoZ = Rad/5;
#declare LogoX = LogoRad2-2*LogoRad1+LogoExtra/2;

#declare NasenkugelGrau = function {pigment {
  image_map {ppm "cuyo.ppm" once interpolate 2}
  translate -1/2
  scale 2*KopfRad
}}


// Die Werte der folgenden Funktionen sind Abstände vom Mittelpunkt der Linie.
// Die Ziffer ist horizontal zentriert.

#declare Ziffer0 = function(X,Z) {
  abs(sqrt(
    pow(X,2)+
    pow(max(0,Z-ZahlKreisZ1,ZahlKreisZ2-Z),2)
  )-ZifferRad)
}

#declare Ziffer2 = function(X,Z) {
  min(
    select(X*ZweiCos+(Z-ZahlKreisZ1)*ZweiSin+ZweiD1,
    Gravurtiefe,select(
      X*ZweiCos+(Z-ZahlKreisZ1)*ZweiSin,
      min(
        sqrt(pow(X+ZweiCos*ZifferRad,2)
          +pow(Z-ZahlKreisZ1-ZweiSin*ZifferRad,2)),
        abs((X+ZifferRad)*ZweiSin
          -(Z-ZahlKreisZ2+ZifferRad)*ZweiCos)),
      abs(sqrt(pow(X,2)+pow(Z-ZahlKreisZ1,2))-ZifferRad)
    )),
    sqrt(pow(Z-ZahlKreisZ2+ZifferRad,2)+
      pow(max(0,X-ZifferRad,-ZifferRad-X),2))
  )
}

#declare Ziffer6 = function(X,Z) {
  min(
    abs(sqrt(pow(X,2)+pow(Z-ZahlKreisZ2,2))-ZifferRad),
    select(Z-ZahlKreisZ2,Gravurtiefe,select(Z-ZahlKreisZ1,
      select(X,
        abs(X+ZifferRad),
        sqrt(pow(X-ZifferRad,2)+pow(Z-ZahlKreisZ1,2))),
      abs(sqrt(pow(X,2)+pow(Z-ZahlKreisZ1,2))-ZifferRad)))
  )
}

#declare Ziffer8 = function(X,Z) {
  // Setzt voraus, daß ZahlLinienHoehe >= 4*ZifferRad.
  abs(sqrt(
    pow(X,2)+
    pow(max(0,abs(abs(Z-ZahlZMitte)-ZahlLinienHoehe/4)
      -ZahlLinienHoehe/4+ZifferRad),2)
  )-ZifferRad)
}


//Kommentieren, wenn man die Stapel schnell anpassen will
#macro Muenze()
  isosurface {
    function {sqrt(
      // Kreisform
      pow(max(0,sqrt(pow(x,2)+pow(z,2))-Rad+Rundheit),2) +
      // Prägung
      pow(max(0,
        abs(y)-HDicke+Rundheit +
        max(0,min(Gravurtiefe,Rad-Rand-sqrt(pow(x,2)+pow(z,2)))) -
        max(0,min(Gravurtiefe,Gravurtiefe-select(y,
            // Ab hier: Abstand vom Mittelpunkt der Linie
          // Rückseite
          Gravurtiefe*NasenkugelGrau(-x,z,0).x,
          // Vorderseite
          select(z-ZahlZMax,
            // Jahreszahl
            select(abs(x)-ZifferBreite,
              // 00   (Eine 0 ist in Wirklichkeit gespiegelt)
              Ziffer0(abs(x)-ZifferBreite/2,z),
              select(x,
                // 2
                Ziffer2(x+ZifferBreite*3/2,z),
                // 8
                Ziffer8(x-ZifferBreite*3/2,z)
              )
            ),
            // Logo
            min(
              // Cu
              select(x-LogoX+LogoRad1+LogoExtra,
                abs(abs(sqrt(pow(x-LogoX+LogoRad1+LogoExtra,2)+pow(z-LogoZ,2))
                  -(LogoRad1+LogoRad2)/2)-(LogoRad2-LogoRad1)/2),
                sqrt(pow(max(0,x-LogoX+LogoRad1),2)+pow(abs(abs(z-LogoZ)
                  -(LogoRad1+LogoRad2)/2)-(LogoRad2-LogoRad1)/2,2))),
              // y (waagerecht)
              sqrt(pow(max(0,LogoX-LogoRad1-LogoExtra-x,x-LogoX),2) +
                pow(z-LogoZ,2)),
              // y (senkrecht)
              sqrt(pow(x-LogoX,2) +
                pow(max(0,abs(z-LogoZ)-LogoRad1-LogoExtra),2)),
              // o
              abs(sqrt(pow(x-LogoX-2*LogoRad1,2)+pow(z-LogoZ,2))-LogoRad1)
            )
          )
        )))
      ),2)
    )}
    threshold Rundheit
    max_gradient 1.5
    contained_by {sphere {0 Rad+HDicke}}
    Textur(texture {Gold})
  }
#end


#ifdef (Version)
  #declare Gross=(Version=-1);
#else
  #declare Gross=0;
#end


#if (Gross)

  /* Zwei Münzen (Vorder- und Rückseite) in Großaufnahme */

  camera {orthographic location -2*z right 4*x up 2*y}

  light_source {<-1,1,-2>*1000 1.5}

  #macro Textur(T) texture{T} #end

  object {
    Muenze()
    rotate 90*x
    rotate 180*z
    translate Rad*1.1*x
    scale 0.9/Rad
  }

  object {
    Muenze()
    rotate -90*x
    translate Rad*-1.1*x
    scale 0.9/Rad
  }

#else

  #ifndef(Version)
    #declare Breite=4;
    #declare Hoehe=4;
  #end

  #include "dungeon.inc"

  #declare Muenz = Muenze()

  #declare Block = union {
    #local II=0;
    #while (II<AnzMuenzen)
      object {
        Muenz
        rotate Muenzen[II][3]*y
        rotate Muenzen[II][4]*x
        rotate Muenzen[II][5]*y
        translate <Muenzen[II][0]+1/2,Muenzen[II][1],Muenzen[II][2]+1/2>
      }
      #local II=II+1;
    #end
  }

  Setze()

#end

