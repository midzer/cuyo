/*
    Copyright 2005 by Immanuel Halupczok
    Based on mrAlle.pov and reversi.inc which, at that time, were
      Copyright 2005 by Mark Weyer
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

#declare Animationsschritte = 6;



light_source {<-1,1,-1>*10000 2/3}
light_source {<0,-2,-1>*10000 1/2}
light_source {<1,0,-2>*10000 1/2}

background {rgb 1}

#declare Eins=<1,1,1>;

#declare AnzahlFarben = 3;

#declare Farbe = array[AnzahlFarben + 1]
  {<1,1/4,0>, <0,2/3,0>, Eins*1/2, Eins*1/20};

#declare WirdzuFarbe = array[AnzahlFarben] {1, 0, 2};

#declare SteinDicke = 1/6;

#macro Stein(Oben,Unten)
  object {
    cylinder {
      <0, 0, -SteinDicke> <0, 0, SteinDicke> 0.8
    }
    pigment {
      gradient z
      colour_map {
        [0 rgb Farbe[Unten]]
        [1/5 rgb Farbe[Unten]]
        [1/5 rgb 1/3*Eins]
        [4/5 rgb 1/3*Eins]
        [4/5 rgb Farbe[Oben]]
        [1 rgb Farbe[Oben]]
      }
      scale 2
      translate -z
      scale (SteinDicke+0.000001)
    }
    finish {
      specular 1/3
      ambient 1/3
    }
  }
#end



camera {
  orthographic
  location -10*z
  direction z
  right 2*AnzahlFarben*x
  up 2*Animationsschritte*y
}

#local I=0;
#while (I<AnzahlFarben)
  #local J=0;
  #while (J<Animationsschritte)
    object {
      #declare farbe=WirdzuFarbe[I];
      #local dreh=J;
      #if (I = 2)
        #local dreh = 0;
	#if (J = 1)
	  #declare farbe=3;
	#end
      #end     
      Stein(I,farbe)
      rotate 180/Animationsschritte*dreh*x
      rotate 60*z
      rotate <20, 10, 10>
      translate (2*I+1-AnzahlFarben)*x
      translate (Animationsschritte-1-2*J)*y
    }
    #local J=J+1;
  #end
  #local I=I+1;
#end

