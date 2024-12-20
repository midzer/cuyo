/*
    Copyright 2010 by Mark Weyer

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


#include "mdEgo.inc"

#declare maxanz = 100000;
#declare pos = array[maxanz];
#declare norm = array[maxanz];
#declare anz = 0;
#declare koerper=Koerper(0);
#declare s=seed(234687);
#declare haar_laenge = 0.07;
#declare minabstand = Haardicke;

#declare i=0;
#while (i<maxanz)
  #declare p=<rand(s)-0.5,rand(s)*0.8,rand(s)-0.5>;
  #if (inside(koerper,p))
    // Schneller Vortest, um möglichst viele schon früh rauszuwerfen
    #declare abstand=100;
    #declare j=0;
    #while (j<anz)
      #declare abstand_ = vlength(p-pos[j]);
      #if (abstand_ < abstand) #declare abstand=abstand_; #end
      #declare j=j+1;
      #if (abstand<minabstand) #declare j=anz; #end
    #end
    #if (abstand>=minabstand)
      #declare hitnorm=<0,0,0>;
      #declare abstand=100;
      #declare j=0;
      #while (j<1000)
        #declare h=rand(s)*2-1;
        #declare phi=rand(s)*2*pi;
        #declare dir=<sqrt(1-h*h)*cos(phi),sqrt(1-h*h)*sin(phi),h>;
        #declare hit=trace(koerper,p,dir,hitnorm);
        #declare d=vlength(hit-p);
        #if (d<abstand & vlength(hitnorm)>0)
          #declare abstand=d;
          #declare pos[anz]=hit;
          #declare norm[anz]=dir;
        #end
        #declare j=j+1;
      #end
      #if (abstand<100)
        #declare abstand=100;
        #declare j=0;
        #while (j<anz)
          #declare abstand_ = vlength(pos[anz]-pos[j]);
          #if (abstand_ < abstand) #declare abstand=abstand_; #end
          #declare j=j+1;
          #if (abstand<minabstand) #declare j=anz; #end
        #end
        #if (abstand>=minabstand) #declare anz=anz+1; #end
      #end
    #end
  #end
  #declare i=i+1;
#end

#fopen raus "mdEgoHaare.data" write
#declare i=0;
#while (i<anz)
  #write(raus, pos[i])
  #write(raus, ", ")
  #write(raus, norm[i])
  #write(raus, ",\n")
  #declare i=i+1;
#end
#fclose raus

