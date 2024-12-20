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

#declare Dreifachlicht = 1;
#declare Hintergrund = 0;

#include "cuyopov.inc"



#declare Kiefer_Radius = 1/3;
#declare Zahnfleisch_Radius = 1/20;
#declare Zahn_Duennheit = 8;

#declare Zahn_Farbe = <1,1,2/3>;
#declare Haut_Farbe = <1,1/2,2/3>;

#declare Haut_finish = finish {
  specular 1/4
}



#macro Zahn_streck(l,w)
  #if (l=1)
    (3/5)
  #end
  #if (l=2)
    #if (mod(w,90)=45)
      1.4
    #else
      1
    #end
  #end
#end



#macro Zahn(l,w)
  intersection {
    sphere {
      0 1
      scale <Zahn_streck(l,w),1/Zahn_Duennheit,1/Zahn_Duennheit>
    }
    box {<0,-1,-1> <2,1,1>}
    Textur(pigment {rgb Zahn_Farbe})
    rotate w*z
  }
#end



#declare Rechts_Rampe = function(x) {select(x,exp(-1/(4*x*x)),0)}

#declare Doppel_Rampe = function(x1,x2,y1,y2,x)
  {(y2*Rechts_Rampe((x1-x)/(x2-x1))+y1*Rechts_Rampe((x-x2)/(x2-x1)))
    / (Rechts_Rampe((x1-x)/(x2-x1))+Rechts_Rampe((x-x2)/(x2-x1)))}

#declare Kiefer_f = function(x,y,z) {
  Doppel_Rampe (0.5,1.5,-2,0,
    pow(
      pow(pow(x/Kiefer_Radius,2)+pow(y/Kiefer_Radius,2),2)+
      pow(z/(1/Zahn_Duennheit+2*Zahnfleisch_Radius),4),
      1/4))
  }



#declare Kreis = function(r,x,y) {
    sqrt(pow(x/r,2)+pow(y/r,2))
  }

#declare Torus = function (r,rr,x,y,z) {
    Kreis (r,x,sqrt(y*y+z*z)-rr)
  }

#declare atanf=function(b,a)				// b=sin, a=cos
  {(select((b),
    select((a),
      select((a)-(b),
        atan2(-(b),-(a))-pi,
        -pi/2-atan2(-(a),-(b))),
      select((a)+(b),
        atan2((a),-(b))-pi/2,
        -atan2(-(b),(a)))),
    select((a),
      select((a)+(b),
        pi-atan2((b),-(a)),
        pi/2+atan2(-(a),(b))),
      select((a)-(b),
        pi/2-atan2((a),(b)),
        atan2((b),(a)))
      )))}

#declare Zahnfleisch_f = function(r,w,x,y,z) {
    Doppel_Rampe (0.5,1.5,-2,0,
      Torus (Zahnfleisch_Radius,r,
        sqrt(x*x+y*y)-Kiefer_Radius,
        (mod(3.5*pi+atanf(y,x)-w*pi/180,pi)-pi/2)*Kiefer_Radius,
        z))
  }

#macro Zahnfleisch(l,w)
  #local rr = sqrt(1-pow(Kiefer_Radius/Zahn_streck(l,w),2))/Zahn_Duennheit
    +Zahnfleisch_Radius;
  +Zahnfleisch_f(rr,w,x,y,z)
#end



#macro Gebiss(H,V,D1,D2)
  union {
    isosurface {
      function {
        Kiefer_f (x,y,z)
        #if (H>0)
          Zahnfleisch(H,0)
        #end
        #if (V>0)
          Zahnfleisch(V,90)
        #end
        #if (D1>0)
          Zahnfleisch(D1,45)
        #end
        #if (D2>0)
          Zahnfleisch(D2,135)
        #end}
      threshold -1
      max_gradient 90
      contained_by {box {
        -(Kiefer_Radius+2*Zahnfleisch_Radius)
        (Kiefer_Radius+2*Zahnfleisch_Radius)}}
    }
    #if (H>0)
      Zahn(H,0)
      Zahn(H,180)
    #end
    #if (V>0)
      Zahn(V,90)
      Zahn(V,270)
    #end
    #if (D1>0)
      Zahn(D1,45)
      Zahn(D1,225)
    #end
    #if (D2>0)
      Zahn(D2,135)
      Zahn(D2,315)
    #end
    Textur(texture{
      pigment {rgb Haut_Farbe}
      finish {Haut_finish}})
    no_shadow
  }
#end

