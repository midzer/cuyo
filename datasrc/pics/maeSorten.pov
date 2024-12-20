/*
    Copyright 2007,2008 by Mark Weyer

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

#declare Breite = 7;
#declare Hoehe = 14;
#declare Normale = Breite*Hoehe-2;
#declare Serie = Normale/3;

#include "aehnlich.inc"


#ifndef(Nur_Umriss)
  plane {
    -z (-3)
    texture {Fassung}
    no_shadow
  }
#end


#declare Anzahl = Breite*Hoehe-2;
#declare Plus = 1/5;
#declare Exp = 3;
#declare Abfall = Plus/pow(1/6,Exp);

#macro PreWert(F)
  (1+Plus-Abfall*pow(abs(F),Exp))
#end

#macro Wert(F)
  (max(0, PreWert(F), PreWert((F)-1), PreWert((F)+1)))
#end

#macro Farbe(T)
  rgb <Wert(T),Wert((T)-1/3),Wert((T)-2/3)>
#end

/*
#declare Kontrast = 1/20;
#macro PreAbstand(W1,W2)
  pow((log(((W1)+Kontrast)/((W2)+Kontrast))),2)
#end
*/

#macro PreAbstand(W1,W2,Gewicht)
  pow((W1-W2)*Gewicht,2)
#end

#macro Abstand(T1,T2)
  #local F1=Farbe(T1);
  #local F2=Farbe(T2);
  sqrt(PreAbstand(F1.red,F2.red,0.299)
    + PreAbstand(F1.green,F2.green,0.587)
    + PreAbstand(F1.blue,F2.blue,0.114))
#end

#declare Ts = array[Anzahl+1];
#declare Ts2 = array[Anzahl];
#declare DSs = array[Anzahl+1];

#local I=0;
#while (I<=Anzahl)
  #declare Ts[I] = I/Anzahl;
  #local I=I+1;
#end

#local Iterationen = 30;
#local I=0;
#while (I<Iterationen)
  #local DS=0;
  #local J=0;
  #while (J<Anzahl)
    #declare DSs[J]=DS;
    #local DS = DS + Abstand(Ts[J],Ts[J+1]);
    #local J=J+1;
  #end
  #declare DSs[Anzahl]=DS;

  #local J_=0;
  #local J=1;
  #while (J<Anzahl)
    #local Ziel = DS*J/Anzahl;
    #while (DSs[J_+1]<=Ziel)
      #local J_=J_+1;
    #end
    #local DS0=DSs[J_];
    #local DS1=DSs[J_+1];
    #declare Ts2[J]=(Ts[J_]*(DS1-Ziel)+Ts[J_+1]*(Ziel-DS0))/(DS1-DS0);
    #local J=J+1;
  #end

  #local J=1;
  #while (J<Anzahl)
    #declare Ts[J] = Ts2[J];
    #local J=J+1;
  #end
  #local I=I+1;
#end



#local I=0;
#while (I<Breite)
  #local J=0;
  #while (J<Hoehe)
    sphere {
      <I-(Breite-1)/2, (Hoehe-1)/2-J, 0>  KugelRad
      Textur(texture {
        pigment {
          #local N = (J*Breite+I);
          #if (N<Anzahl)
            Farbe(Ts[N])
          #else#if (N=Anzahl)
            rgb 0
          #else
            rgb 1/3
          #end#end
        }
        finish {Finish}
      })
      no_shadow
    }
    #local J=J+1;
  #end
  #local I=I+1;
#end
