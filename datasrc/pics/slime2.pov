/*
    Copyright 2005 by Mark Weyer
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

#declare Breite=5;
#declare Hoehe=1;

#ifndef(Case)
  #declare Case=1;
  #declare Breite=8;
  #declare Hoehe=6;
#end

#ifndef(Time)
  #declare Time = 100;
#end

#declare Hintergrund=0;


#include "cuyopov.inc"



#if(Case=1)
  #declare Colour=<0,1,0>;
  #declare Stream = seed(2);
#end

#if(Case=2)
  #declare Colour=<1,0,0>;
  #declare Stream = seed(1);
#end


global_settings {
  max_trace_level 100
}

#declare Angle_deg = 0;
#declare Angle_rad = Angle_deg*pi/180;
#declare Height = 1/cos(Angle_rad);

#declare Blob_aux_func = function(a){pow(1-pow(a,2),2)}

#declare Main_num = 100;
#declare Main_rad = 1/4;
#declare Main_strength = 3;
#declare Main_thick = 1/4;

//#declare Blob_func = function(X,Y,Z){Blob_aux_func(min(1,sqrt(X*X+Y*Y+Z*Z)/Main_rad))}
#declare Blob_func = function(X,Y,Z){pow(max(0,1-(X*X+Y*Y+Z*Z)/(Main_rad*Main_rad)),2)}

#macro Main_func(P)
  function (X,Y,Z) {
    1-Main_strength*(0
    #local XX=-3;
    #while (XX<4)
      #local YY=-1;
      #while (YY<2)
        #local i=0;
        #while (i<Main_num)
          #if (Blob_test(XX,YY,Main_pos[i][0],Main_pos[i][1],P))
            +Blob_func(
              X-XX-Main_pos[i][0],
              Y-YY-Main_pos[i][1],
              Z-Main_pos[i][2])
          #end
          #local i=i+1;
        #end
        #local YY=YY+1;
      #end
      #local XX=XX+1;
    #end
    )
  }
#end

#declare Main_pos = array[Main_num][3];

#local i=0;
#while (i<Main_num)
  #declare Main_pos[i][0]=rand(Stream);
  #declare Main_pos[i][1]=rand(Stream)*Height;
  #declare Main_pos[i][2]=(rand(Stream)-1/2)*Main_thick;
  #local i=i+1;
#end

#macro Xor(A,B)
  ((A)&(!(B))) | ((B)&(!(A)))
#end

#macro Mod(A,B)
  (A)-floor((A)/(B))*(B)
#end

#macro Blob_pretest(X,Y,P)
  Xor(P,(Mod(X+Y+Y,5)=0))
#end

#macro Blob_test(X,Y,XX,YY,P)
  (Blob_pretest(X,Y,P) &
  (Blob_pretest(X-1,Y,P) | (XX>=Main_rad)) &
  (Blob_pretest(X+1,Y,P) | (XX<=1-Main_rad)) &
  (Blob_pretest(X,Y-1,P) | (YY>=Main_rad)) &
  (Blob_pretest(X,Y+1,P) | (YY<=Height-Main_rad)) &
  (Blob_pretest(X-1,Y-1,P) | (pow(XX,2)+pow(YY,2)>=pow(Main_rad,2))) &
  (Blob_pretest(X-1,Y+1,P) | (pow(XX,2)+pow(Height-YY,2)>=pow(Main_rad,2))) &
  (Blob_pretest(X+1,Y+1,P) | (pow(1-XX,2)+pow(Height-YY,2)>=pow(Main_rad,2))) &
  (Blob_pretest(X+1,Y-1,P) | (pow(1-XX,2)+pow(YY,2)>=pow(Main_rad,2))))
#end

#macro Bubble_rad1(T) (pow((T)+1,1/3)/5) #end
#macro Bubble_rad2(T) (Bubble_rad1(T)*0.9) #end
#macro Bubble_pos(T)
  (<1/2,Height/2,Main_thick/2>+<0,0,-Bubble_rad1(T)>*((T)-2)/2) #end
#macro Bubble_strength1(T) 100 #end
#macro Bubble_strength2(T) (Bubble_strength1(T)*1.1) #end





#macro Obj_Mod()
  Textur(texture {
    pigment {color <0,0,0,0,1>}
    finish {
      ambient 0
      specular 1/3
    }
  })
  interior_texture {
    pigment {color <0,0,0,0,1>}
    finish {ambient 0}
  }
  no_shadow
  hollow
  interior {
    media {
      scattering {1, rgb Colour*2}
    }
  }
#end


#macro Obj(P)
  blob {
    #local X=-3;
    #while (X<4)
      #local Y=-1;
      #while (Y<2)
        #if (Blob_pretest(X,Y,P))
          #local i=0;
          #while (i<Main_num)
            #if (Blob_test(X,Y,Main_pos[i][0],Main_pos[i][1],P))
              sphere {
                <Main_pos[i][0]+X,Main_pos[i][1]+Y*Height,Main_pos[i][2]>
                Main_rad
                Main_strength
              }
            #end
            #local i=i+1;
          #end
          sphere {
            <X,Y*Height,0>+Bubble_pos(Time)
            Bubble_rad1(Time),
            -Bubble_strength1(Time)
          }
          sphere {
            <X,Y*Height,0>+Bubble_pos(Time)
            Bubble_rad2(Time)
            Bubble_strength2(Time)
          }
        #end
        #local Y=Y+1;
      #end
      #local X=X+1;
    #end
    threshold 1
    Obj_Mod()
    translate <-1/2,-Height/2,0>
    rotate Angle_deg*x
  }
#end

Obj(0)
Obj(1)


