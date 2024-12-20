/*
    Copyright 2010,2014 by Mark Weyer
    Maintenance 2011 by the cuyo developers

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

#declare Spezial_Einzel = 1;

#include "dungeon.inc"

#declare Augenabstand = 0.2;
#declare Augen_z = -0.2;
#declare Ohr1 = <0.25,2,0>;
#declare Ohr2 = <0.45,2.1,0>;
#declare Ohrwinkel = -5;
#declare Handpos = <0.4, 0.8, -0.14>;
#declare Handscale = 0.22;
#declare Fingerglied2 = <-0.3,0,-0.05>;
#declare Fingerglied3 = <0,0,0.25>;
#declare Fingerglied4 = <0.14,0,0>;
#declare Fusspos = <0.27,0,0>;
#declare Beindicke = 0.15;
#declare Haarlaenge = 0.07;
#declare Haardicke = Haarlaenge/10;

#macro Lid(winkel,welche)
  sphere {
    0 1 1
    scale <0.15,0.12,0.04>
    rotate winkel*x
    rotate 10*z
    translate <Augenabstand/2,Augenhoehe,Augen_z>
    scale welche
  }
#end

#macro Horn(hoehe,winkel)
  #local laenge = 0.35-(1.15-hoehe)*(1.15-hoehe);
  cylinder {
    0 laenge*z 0.04 1/2
    scale <0.6,1,1>
    rotate winkel*x
    translate hoehe*y
  }
  sphere {
    laenge*z laenge/4 (-0.15)
    rotate winkel*x
    translate hoehe*y
  }
#end

#macro Finger(laenge,hoehe,welche)
  #local Fingerglied1 = <0,hoehe*0.044,-0.4>;

  #local trans1 = transform {
    translate <laenge*0.2,hoehe*0.099,0>
    scale Handscale
    translate Handpos
    scale welche
  }
  #local trans2 = transform {
    translate laenge*Fingerglied1
    transform trans1
  }
  #local trans3 = transform {
    translate laenge*Fingerglied2
    transform trans2
  }
  #local trans4 = transform {
    translate laenge*Fingerglied3
    transform trans3
  }
  cylinder {
    0 laenge*Fingerglied1 0.11 1
    transform trans1
  }
  sphere {
    0 0.1 (-1)
    transform trans2
  }
  cylinder {
    0 laenge*Fingerglied2 0.1 1
    transform trans2
  }
  sphere {
    0 0.1 (-1)
    transform trans3
  }
  cylinder {
    0 laenge*Fingerglied3 0.1 1
    transform trans3
  }
  sphere {
    0 0.1 (-1)
    transform trans4
  }
  cylinder {
    0 laenge*Fingerglied4 0.1 1
    transform trans4
  }
#end

#macro Daumen(welche)
  #local trans = transform {
    translate <0.15,0.2,0>
    scale Handscale
    translate Handpos
    scale welche
  }
  #local punkt1 = <-0.03,0.11,-0.2>;
  #local punkt2 = <-0.05,0.12,-0.33>;
  #local punkt3 = <-0.06,0.13,-0.4>;
  cylinder {
    0 punkt1 0.11 1
    transform trans
  }
  sphere {
    punkt1 0.1 (-1)
    transform trans
  }
  cylinder {
    punkt1 punkt2 0.1 1
    transform trans
  }
  sphere {
    punkt2 0.1 (-1)
    transform trans
  }
  cylinder {
    punkt2 punkt3 0.1 1
    transform trans
  }
#end

#macro BlobHaelfte(mitArmen,welche)

  //Hals
  cylinder {
    1.3*y Augenhoehe*y 0.15 1/2
  }

  // Schaedel
  cylinder {
    1.7*y <0.1, 2.1, 0.2> 0.2 1
    scale welche
  }
  sphere {
    <0.125, 2.1, -0.05> 0.25 1
    scale welche
  }
  sphere {
    0 1 1/2
    scale <0.4, 0.2, 0.1>
    translate <0,Augenhoehe,Augen_z+0.03>
  }
  sphere {
    <0, 1.8, -0.1> 0.3 1/2
  }
  sphere {
    0 0.25 1/2
    scale <1,0.3,1>
    rotate 10*x
    translate <0,2.15,0.1>
  }

  // Augen
  Lid(-30,welche)
  Lid(40,welche)

  // Ohren
  cylinder {
    Ohr1 Ohr2 0.1 1
    scale <1,1,0.3>
    rotate Ohrwinkel*y
    scale welche
  }
  cylinder {
    Ohr1 Ohr2-0.01*z 0.05 (-1)
    translate -(Ohr1+Ohr2)/2
    scale <0.8,0.8,0.7>
    translate (Ohr1+Ohr2)/2
    rotate Ohrwinkel*y
    translate -0.03*z
    scale welche
  }
  sphere {
    Ohr2 0.2 (-1/3)
    scale welche
  }

  // Ruessel
  cylinder {
    <0, 1.9, -0.1> <0, 1.8, -0.4> 0.07 1/2
  }
  cylinder {
    <0, 1.95, 0.05> <0, 1.75, -0.55> 0.025 (-1/2)
  }

  // Ruecken
  cylinder {
    <0.15, 1.3, 0.3> <0.1, 0.8, 0.2> 0.3 1
    scale <1,1,0.5>
    scale welche
  }
  Horn(1.3, -9)
  Horn(1.2, -7)
  Horn(1.1, -5)
  Horn(1, -3)
  Horn(0.9, -1)
  Horn(0.8, 1)
  cylinder {
    <0.2, 1.3, 0> <0.15, 1, 0> 0.2 1
    scale welche
  }

  // Brust
  cylinder {
    <0,1.2,-0.3> <0,0.9,-0.2> 0.5 1/2
    scale <1,1,0.4>
    scale welche
  }
  // Muskeln
  sphere {
    0 0.2 1/3
    scale <0.9,0.8,0.3>
    rotate 2*x
    rotate -10*y
    translate <0.15, 1.25, -0.19>
    scale welche
  }
  sphere {
    0 0.15 1/3
    scale <0.8,0.6,0.2>
    rotate -5*y
    translate <0.1, 1.05, -0.195>
    scale welche
  }
  sphere {
    0 0.125 1/3
    scale <0.7,0.5,0.15>
    rotate -5*y
    translate <0.07, 0.95, -0.194>
    scale welche
  }

  #if (mitArmen)
    // Arm
    cylinder {
      <0.37, 1.3, 0.05> <0.4, 0.9, 0.2> 0.1 1
      scale welche
    }
    sphere {
      <0.4, 0.9, 0.2> 0.1 (-1)
      scale welche
    }
    cylinder {
      <0.41, 0.8, -0.1> <0.4, 0.9, 0.2> 0.1 1
      scale welche
    }
    sphere { // Bizeps
      0 0.2 1/3
      scale <0.4, 0.9, 0.1>
      rotate 10*z
      rotate -15*y
      rotate -20*x
      translate <0.38, 1.1, 0.065>
      scale welche
    }
    Finger(0.9,-1.5,welche)
    Finger(0.97,-0.5,welche)
    Finger(1,0.5,welche)
    Finger(0.97,1.5,welche)
    Daumen(welche)
  #end

  // Bein
  cylinder {
    <0.17,0.8,0> Fusspos+Beindicke*y Beindicke 1
    scale welche
  }
#end

#macro Koerper(mitArmen)
  blob {
    BlobHaelfte(mitArmen,1)
    BlobHaelfte(mitArmen,<-1,1,1>)
    threshold 0.5
    Textur(texture{
      pigment {rgb <0.1,0.6,0.5>}
      finish {brilliance 2 specular 0.2}
    })
  }
#end


#ifdef(Richtung)

  #declare Auge = sphere {
    0 1/2
    Textur(texture{
      pigment {image_map {"mdAuge.ppm"} translate 1/2}
    })
    scale 1/7
  }

  #declare Huf = difference {
    intersection {
      isosurface {
        function {
          - cos(y*170)*Beindicke/170
          + sqrt(x*x+z*z) + (y-2*Beindicke)*0.3}
      }
      box {<-1,0,-1> 1}
    }
    box {
      -1 1
      rotate 45*y
      scale <0.2,1,1>
      translate -1.4*z
    }
    Textur(texture{
      pigment {rgb 1/5}
      finish {specular 0.5}
    })
    translate Fusspos
  }

  #macro Haare()
    #declare P = <1,2,3>;
    #declare N = <1,2,3>;
    #local durchhang = Haarlaenge;

    #fopen rein "mdEgoHaare.data" read
    #read(rein P N)
    #while (defined(rein))
      sphere_sweep {
        cubic_spline 4
        P-Haarlaenge*N Haardicke
        P Haardicke
        P+Haarlaenge*N-durchhang*y Haardicke/2
        P+1.5*Haarlaenge*N-3*durchhang*y 0
        Textur(texture{
          pigment {rgb <0.3,0.1,0>}
          finish {specular 0.2}
        })
      }
      #read(rein P N)
    #end
  #end

  #declare Block = union {
    object {Auge translate <-Augenabstand/2,Augenhoehe,Augen_z>}
    object {Auge translate <Augenabstand/2,Augenhoehe,Augen_z>}

    Koerper(1)

    Haare()

    object {Huf}
    object {Huf scale <-1,1,1>}

    translate -Augen_z*z
    rotate Richtung*y
    translate <1/2,0,1/2>
  }

  Setze()

#end

