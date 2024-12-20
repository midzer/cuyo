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

#include "dungeon.inc"

#declare Rad = 0.15;
#declare Rad2 = 0.3;
#declare Rad3 = 0.1;
#declare Teile = 500;
#declare Rand = seed(65432);

#declare APunkte = 4;
#declare Punkte = array [APunkte] [2] {
  {0,0},
  {Rad2,Rad},
  {Rad2/2,BlockHoehe*2/3}
  {0,BlockHoehe*3/4}
}

#declare Winkel = array [APunkte]
#declare Laengen = array [APunkte-1]
#declare GesamtWinkel = array[APunkte+1]
#declare GesamtLaenge = array[APunkte+1]

#declare GesamtLaenge[0] = 0;
#declare GesamtWinkel[0] = 0;
#local I=1;
#while (I<APunkte)
  #local DR = Punkte[I][0] - Punkte[I-1][0];
  #local DY = Punkte[I][1] - Punkte[I-1][1];
  #if (abs(DR)>DY)
    #if (DR>=0)
      #declare GesamtWinkel[I] = atan2(DY,DR);
    #else
      #declare GesamtWinkel[I] = pi-atan2(DY,-DR);
    #end
  #else
    #declare GesamtWinkel[I] = pi/2-atan2(DR,DY);
  #end
  #declare Winkel[I-1] = GesamtWinkel[I]-GesamtWinkel[I-1];
  #declare Laengen[I-1] = sqrt(DR*DR+DY*DY);
  #declare GesamtLaenge[I] = GesamtLaenge[I-1]+Rad*Winkel[I-1]+Laengen[I-1];
  #local I=I+1;
#end
#declare GesamtWinkel[APunkte] = pi;
#declare Winkel[APunkte-1] = pi-GesamtWinkel[APunkte-1];
#declare GesamtLaenge[APunkte] = GesamtLaenge[APunkte-1]+Rad*Winkel[APunkte-1];



#declare Stein = function {pattern {
  marble
  turbulence 0.6
  scale 0.07
  rotate 15*z
  rotate 20*y
}}

#declare Block = intersection {
  #local I=0;
  #while (I<Teile)
    #local Suche=1;
    #while (Suche)
      #local TT = rand(Rand)*GesamtLaenge[APunkte];
      #local Punkt = 0;
      #while (TT>GesamtLaenge[Punkt+1])
        #local Punkt=Punkt+1;
      #end
      #local TT=TT-GesamtLaenge[Punkt];

      #if (TT>Rad*Winkel[Punkt])
        #local WW = GesamtWinkel[Punkt+1];
        #local UU = (TT-Rad*Winkel[Punkt])/Laengen[Punkt];
        #local RR = Punkte[Punkt+1][0]*UU + Punkte[Punkt][0]*(1-UU)
          + Rad*sin(GesamtWinkel[Punkt+1]);
        #local YY = Punkte[Punkt+1][1]*UU + Punkte[Punkt][1]*(1-UU)
          - Rad*cos(GesamtWinkel[Punkt+1]);
      #else
        #local WW = GesamtWinkel[Punkt]+TT/Rad;
        #local RR = Punkte[Punkt][0]+Rad*sin(WW);
        #local YY = Punkte[Punkt][1]-Rad*cos(WW);
      #end

      #if (rand(Rand)*0.5<=RR)
        #local Suche=0;
      #end
    #end
    #local WW2 = rand(Rand)*360;
    #local DD = (1+rand(Rand))*Rad3;
    #local JJ = 0;
    #while (JJ<4)
      merge {
        sphere {0 DD}
        plane {y 0}
        inverse
        translate -DD*y
        rotate WW*180/pi*z
        translate <RR,YY,0>
        rotate (WW2+90*JJ)*y
      }
      #local JJ=JJ+1;
    #end
    #local I=I+1;
  #end

  bounded_by {cylinder {-y (BlockHoehe+1)*y 1/2}}

  Textur(texture {
    pigment {
      function {
        (select(x,-x*(Stein(-x,y,-z)-0.5),x*(Stein(x,y,z)-0.5)) +
        select(z,-z*(Stein(-z,y,x)-0.5),z*(Stein(z,y,-x)-0.5)))
          / (2*sqrt(pow(x,2)+pow(z,2))+1e-4) + 0.5}
      #local Helligkeit=1/2;
      colour_map {
        [0.4 rgb 1/3*Helligkeit]
        [0.5 rgb <1,1,2>/2*Helligkeit]
        [0.6 rgb 1/4*Helligkeit]
        [0.55 rgb 3/5*Helligkeit]
      }
    }
    finish {
      specular 0.2
    }
  })

  translate <1/2,0,1/2>
}

Setze()

