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

#ifdef(Version)
  #if (Version<36)
    #declare KeineBlumen = 1;
  #end
#end

#declare Zuf = seed(1984);

#macro Grashalm()
  #local Stroh = pow(rand(Zuf),4);
  #local Farbe1 = rgb <Stroh,1,0>/2;
  #local Farbe2 = rgb <Stroh*2/3,1/2,0>/2;
  #local Breite = pow(rand(Zuf),1/3)/4;
  #local Rad = (rand(Zuf)+2)/5;

  sphere {
    (Rad-Breite)*z Rad
    clipped_by {plane {x 0}}
    clipped_by {plane {-x 0 rotate 10*y}}
    pigment {radial
      colour_map{[0 Farbe2][1/2 Farbe1][1 Farbe2]}
      frequency 108
    }
    finish {ambient 1/3}
    translate Breite*z
    rotate 360*rand(Zuf)*y
  }
#end


#declare Bozof1 = function {pattern {bozo scale 1/300}}

#macro Blumenstiel(Stempeldicke,Stempelflachheit,Hoehe)
  #local Stengeldicke = 1/50;
  #local Bozoschieb = 100*rand(Zuf);
  union {
    sphere_sweep {
      b_spline BB_Segmente+3
      #local I=-1;
      #while (I<=BB_Segmente+1)
        Hoehe*I/BB_Segmente*y
          #if (I!=BB_Segmente)
            + vrotate(rand(Zuf)*Stengeldicke*2*x, 360*rand(Zuf)*y)
          #end
        Stengeldicke
        #local I=I+1;
      #end
      pigment {rgb <1/5,4/5,1/7>}
    }
    isosurface {
      function {sqrt(x*x + Stempelflachheit*y*y + z*z)
        + Stengeldicke*(Bozof1(x+Bozoschieb,y,z)-1/2)}
      threshold Stempeldicke*Stengeldicke
      max_gradient 8
      contained_by {sphere {0 3*Stengeldicke} }
      translate Hoehe*y
      pigment {rgb <1,5/6,0>}
    }
  }
#end


#declare BB_Segmente = 3;
#declare BB_Bluetenblaetter = 13;

#macro BlumeBlau()
  #local Hoehe = 1/3+rand(Zuf)/6;
  union {
    Blumenstiel(2,3,Hoehe)
    #local I=0;
    #while (I<BB_Bluetenblaetter)
      plane {
        #local R1 = 1/7 + rand(Zuf)*1/29;
        #local R2 = R1 * (19+2*rand(Zuf))/20;
        #local X = R1*sqrt(3/4);
        #local Z = R1/2;
        y 0
        clipped_by {sphere {<X,0,Z> R2}}
        clipped_by {sphere {<-X,0,Z> R2}}
        pigment {
          function {abs(x)/(sqrt(pow(R2,2)-pow(z-Z,2))-X)}
          colour_map{[0 rgb <1/6,1/2,1>][1 rgb <0,1/6,1>]}
        }
        rotate (rand(Zuf)*10-5)*z
        rotate -(rand(Zuf)*10)*x
        rotate (rand(Zuf)*5 + 360/BB_Bluetenblaetter*I)*y
        translate Hoehe*y
      }
      #local I=I+1;
    #end
    rotate 360*rand(Zuf)*y
  }
#end


#declare Bozof2 = function {pattern {bozo scale <1/50,1,1/50>}}
#declare BR_Bluetenblaetter = 7;

#macro BlumeRot()
  #local Hoehe = 1/3+rand(Zuf)/6;
  #local Farbe1 = rgb <1,rand(Zuf)/9,rand(Zuf)/7>;
  #local Farbe2 = rgb <(1+rand(Zuf))/3,0,0>;
  union {
    Blumenstiel(3/2,1,Hoehe)
    #local I=0;
    #while (I<BR_Bluetenblaetter)
      #local Rad = 1/11+1/23*rand(Zuf);
      #local Bozoschieb = 100*rand(Zuf);
      sphere {
        0 Rad
        clipped_by {sphere {Rad*x Rad rotate 360*I/BR_Bluetenblaetter*y}}
        clipped_by {isosurface {
          function {5*y + Bozof2(x,y,z+Bozoschieb) + Bozof1(x,y+Bozoschieb,z)/5}
          threshold 3/5
          contained_by {sphere {0 4/3*Rad}}
        }}
        pigment {
          bozo
          scale <1/30,1/5,1/30>
          colour_map {[2/5 Farbe1][1/2 Farbe2][3/5 Farbe1]}
        }
        translate (Hoehe+Rad/2)*y
      }
      #local I=I+1;
    #end
    rotate 360*rand(Zuf)*y
  }
#end


#macro Blume()
  #if (rand(Zuf)>1/3)
    BlumeBlau()
  #else
    BlumeRot()
  #end
#end


#declare Gras = union {
  #local I=0;
  #while (I<140)
    object {Grashalm() translate <rand(Zuf),0,rand(Zuf)>}
    #local I=I+1;
  #end
  translate -1/2
}

#declare Beet = union {
  object {Gras}
  object {Gras rotate 90*y}
  object {Gras rotate 180*y}
  object {Gras rotate 270*y}
  translate 1/2
}

#declare Einheit = union {
  object {Beet}
  object {Beet translate x}
  object {Beet translate z}
  object {Beet translate x+z}

  #ifndef(KeineBlumen)
    #local I=0;
    #while (I<11)
      object {
        Blume() translate <2*rand(Zuf),0,2*rand(Zuf)>}
      #local I=I+1;
    #end
  #end
}

#declare Boden = union {
  #ifdef(Breite)
    #local Imax = Breite/4;
    #local Imin = -Imax;
    #local Jmax = BodenHoehe/4;
    #local Jmin = -Jmax;
  #else
    #local Imin=-4;
    #local Imax=4;
    #local Jmin=-4;
    #local Jmax=4;
  #end

  #local I=Imin;
  #while (I<Imax)
    #local J=Jmin;
    #while (J<Jmax)
      object {Einheit translate <2*I,0,2*J>}
      #local J=J+1;
    #end
    #local I=I+1;
  #end
}

