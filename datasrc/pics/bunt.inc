/*
    Copyright 2005,2006 by Mark Weyer
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

global_settings {
  max_trace_level 200
}

#declare FesteFarben = 8;
#declare Farben = 2*FesteFarben;


#declare Hintergrund = 1;
#declare Dreifachlicht = 1;
#declare Breite=Breite1*Farben+Breite0;
#declare Hoehe=Hoehe1*Farben+Hoehe0;

#include "cuyopov.inc"




#declare Rad_gross = 0.9;
#declare Rad_klein = Rad_gross/pow(2,1/3);

#declare FesteFarben = 8;
#declare Farben = 2*FesteFarben;

#declare Farbe = array[Farben];

#local N=0;
#while (N<FesteFarben)
  #local A=3*(N+1/2)/FesteFarben;
  #local F=mod(N+1,2)/4;
  #local B=(mod(A,1)+1)/2-1/7;
  #local C=3/2-B-2/7;
  #local E=1/3;
  #if (A<1)
    #declare Farbe[N]=<C+F,B+F,E+F,0>;
  #else
    #if (A<2)
      #declare Farbe[N]=<E+F,C+F,B+F,0>;
    #else
      #declare Farbe[N]=<B+F,E+F,C+F,0>;
    #end
  #end
  #declare Farbe[N+FesteFarben]=Farbe[N]+<0,0,0,1>;
  #local N=N+1;
#end




#declare Seite = array[Farben][Farben];

#local Zufall = seed(58);

#local N=0;
#while (N<Farben)
  #local M=0;
  #while (M<=N)
    #if (rand(Zufall)>=0.5)
      #declare Seite[M][N] = -1;
      #declare Seite[N][M] = 1;
    #else
      #declare Seite[M][N] = 1;
      #declare Seite[N][M] = -1;
    #end
    #local M=M+1;
  #end
  #local N=N+1;
#end



#declare Threshold = 0.5;

#declare Bozo = function{pattern {bozo scale 1/2}}

#declare Misch = function (X,Y,Z,I,J,D,S) {
    min(1,max(0,S*(Bozo(X+2*min(I,J),Y-D/2+4*max(I,J),Z)-1/2+X*cos(D*pi/4)/2)
                +1/2+(Y-D/2)*sin(D*pi/4)/2))
  }

#macro Bunt_mods(I,J,D)
  Textur(texture{
    pigment {
      function {Misch(x,y,z,I,J,D,Seite[I][J])}
      colour_map {[1/2 rgbt Farbe[I]] [1/2 rgbt Farbe[J]]}
    }
    finish {specular 1/3 ambient 1/3}
  })
  no_shadow
  hollow
  interior {media {
    absorption 6
    density {
      function {Misch(x,y,z,I,J,D,Seite[I][J])}
      colour_map {[1/2 rgbt 1-Farbe[I]] [1/2 rgbt 1-Farbe[J]]}
    }
  }}
#end

#macro Bunt_iso(D,Th)
  isosurface {
    #if (D>=1)
      // Die Funktion Radius^2 hat die Gestalt
      //   (Alpha*|y|+Beta)*(|y|-Gamma)*(|y|-Delta)
      // beziehungsweise C3*|y|^3+C2*|y|^2+C1*|y|+C0
      // Dabei ist Alpha,Beta>=0 und 0<=Gamma<Delta,
      // also sind Gamma und Delta die einzigen Nullstellen >0
      // Das ganze wird dann so skaliert, daß das Volumen des Körpers stimmt
      #local T=2-D;
      #local TT=1-T;
      #local Alpha=T;
      #local Beta=TT;
      #local Gamma=TT*(1-Rad_klein);
      #local Delta=TT*(1+Rad_klein) + T*(1+Rad_klein+Rad_gross)/2;
      #local C3=Alpha;
      #local C2=Beta-Alpha*(Gamma+Delta);
      #local C1=Alpha*Gamma*Delta-Beta*(Gamma+Delta);
      #local C0=Beta*Gamma*Delta;
      #local Volumen = C3/4*(pow(Delta,4)-pow(Gamma,4))
        +C2/3*(pow(Delta,3)-pow(Gamma,3))
        +C1/2*(pow(Delta,2)-pow(Gamma,2))
        +C0*(Delta-Gamma);
      #local Skalierung = 4/3*pow(Rad_klein,3)/Volumen;

      function {x*x+z*z
        -(C3*pow(abs(y),3)+C2*pow(abs(y),2)+C1*abs(y)+C0)*Skalierung}
    #else
      // Jetzt, nach dem Kontakt, hat Radius^2 die Gestalt
      //   (Alpha*y^2+Beta)*(y^2-Gamma^2)
      // bezeihungsweise C4*y^4+C2*y^2+C0
      // Dabei ist wieder Alpha,Beta,Gamma>=0,
      // also ist Gamma die einzige Nullstelle >0
      // Skalierung wieder nach Volumen
      #local T=1-D;
      #local TT=1-T;
      #local Alpha=TT;
      #local Beta=T;
      #local Gamma=TT*(1+Rad_klein+Rad_gross)/2+T*Rad_gross;
      #local C4=Alpha;
      #local C2=Beta-Alpha*Gamma*Gamma;
      #local C0=-Beta*Gamma*Gamma;
      #local Volumen = C4/5*pow(Gamma,5)+C2/3*pow(Gamma,3)+C0*Gamma;
      // Dies ist nur das Volumen für die obere Hälfte,
      // also wird es nur mit Rad_klein verglichen
      #local Skalierung = 4/3*pow(Rad_klein,3)/Volumen;

      function {x*x+z*z-(C4*pow(y,4)+C2*pow(y,2)+C0)*Skalierung}
    #end
    threshold Th
    max_gradient 10
    contained_by {box {<-1,-2,-1> <1,2,1>}}
    translate D/2*y
  }
#end



#macro Bunt_voll (D)
  Bunt_iso(D,0)
#end

#macro Bunt_hohl (D)
  difference {
    Bunt_iso(D,0)
    Bunt_iso(D,-0.1)
  }
#end

#macro Misch_shape (I,J,D,T)
  isosurface {
    function {Misch(x,y,z,I,J,D,Seite[I][J])}
    threshold T
    max_gradient 2.6
    contained_by {box {-1 1+y}}
  }
#end

#macro Bunt (I,J,D)
  #if (I<FesteFarben)
    #if (J<FesteFarben)
      object {
        Bunt_voll(D)
        Bunt_mods(I,J,D)
      }
    #else
      union {
        intersection {
          Bunt_voll (D)
          Misch_shape (I,J,D,1/2-1e-2)
          Bunt_mods(I,I,D)
        }
        difference {
          Bunt_hohl (D)
          Misch_shape (I,J,D,1/2+1e-2)
          Bunt_mods(J,J,D)
        }
      }
    #end
  #else
    #if (J<FesteFarben)
      union {
        intersection {
          Bunt_hohl (D)
          Misch_shape (I,J,D,1/2-1e-2)
          Bunt_mods(I,I,D)
        }
        difference {
          Bunt_voll (D)
          Misch_shape (I,J,D,1/2+1e-2)
          Bunt_mods(J,J,D)
        }
      }
    #else
      object {
        Bunt_hohl(D)
        Bunt_mods(I,J,D)
      }
    #end
  #end
#end


