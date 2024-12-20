/*
    Copyright 2006,2011,2014 by Mark Weyer

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
  #declare Gross=(Version=-1);
#else
  #declare Gross=0;
#end

#declare ErstHoehe = 1.3;
#declare Aura = 0.1;
#declare Blattgroesse = 0.1;
#declare BlattGruen1 = rgb <0,0.7,0.2>*0.7;
#declare BlattGruen2 = rgb <0.1,0.85,0.1>*0.7;
#declare BlattTeile = 6;
#declare HolzBraun = rgb <1/3,1/5,0>;

#declare Zuf1 = seed(853211);
#declare Zuf2 = seed(112358);
#declare Zuf3 = seed(11235);


#macro Streu(V,F)
  #local V_=(V);
  #local D=1;
  #while (vlength(D)>1)
    #local D=2*<rand(Zuf1),rand(Zuf2),rand(Zuf1)>-1;
  #end
  #local D=D/vlength(D);
  #local D=D*vlength(V_)*F;
  #local V_=D+V_*(1-vdot(D,V_)/vdot(V_,V_));
  V_
#end


#declare Rinde = function{pattern{bozo scale <1,1,2>/20}}

#declare PraeStamm = function(L,R1,R2,TA,CA,X,Y,Z) {
  min(0,max(-2*Aura,-Aura
    + select(Z-R1*TA,
      sqrt(X*X+Y*Y+Z*Z)-R1,
      select(Z-L-R2*TA,
        sqrt(X*X+Y*Y)-CA*(R1+(R2-R1)*(Z-R1*TA)/(L+(R2-R1)*TA)),
        sqrt(X*X+Y*Y+(Z-L)*(Z-L))-R2))
    + (Rinde((X*X*X*X-6*X*X*Y*Y+Y*Y*Y*Y)/(X*X+Y*Y)/sqrt(X*X+Y*Y),
      4*X*Y*(X*X-Y*Y)/(X*X+Y*Y)/sqrt(X*X+Y*Y),
      Z)-1/2)*Aura))
}

#declare Stamm=function(x,y,z) {
  #local L = ErstHoehe;
  #local R1=1/9;
  #local R2=1/10;
  #local Alpha = asin((R1-R2)/L);
  #local TA = tan(Alpha);
  #local CA = cos(Alpha);

  PraeStamm(L,R1,R2,TA,CA,x,z,y)
}


#macro Cone(P1,R1,P2,R2)
  #local D = P2-P1;
  #local DR = R1-R2;
  #local Alpha = asin(DR/vlength(D));
  #local CA = cos(Alpha);
  union {
    cone {
      P1+D/vdot(D,D)*R1*DR
      R1*CA
      P2+D/vdot(D,D)*R2*DR
      R2*CA
    }
    sphere {
      P2 R2
    }
  }
#end


#declare BlattPigH = pigment {
  checker
  pigment {
    checker
    pigment {BlattGruen1}
    pigment {BlattGruen2}
    translate y*(1-1/7)
  }
  pigment {BlattGruen2}
  scale <1e5,1e-5,1>
}

#declare BlattPig = pigment {
  checker
  pigment {
    checker
    pigment {BlattGruen1}
    pigment {BlattPigH}
    translate x*(1-1/3)
  }
  pigment {BlattPigH}
  translate z/2
  scale <1,1e5,1>
}


#macro Blatt(P,D)
  #local R=sqrt(D.x*D.x+D.z*D.z);
  #local Theta=atan2(R,D.y);
  #if (R<1e-6)
    #local Phi=0;
  #else
    #local Phi=atan2(D.x,D.z);
  #end
  #local L=vlength(D);

  union {
    #local P1=0;
    #local DD=L/BlattTeile*y;
    #local Bieg=(1+2*rand(Zuf3))*10;
    #local Knick=rand(Zuf3)*5;
    #local Spreiz=rand(Zuf3)*30;
    #local RStiel=L/40;
    #local DRStiel=RStiel/(1.5*BlattTeile);
    #local Rechts=1+rand(Zuf3);
    #local Links=1+rand(Zuf3);

    #local I=0;
    #while (I<BlattTeile)
      #local T=I/BlattTeile;
      #local Seit=L*((1-T)*pow(1-1/BlattTeile,2)-pow(1-T,3));
      #local P2=P1+vrotate(DD,Bieg*T*x);
      #local RStiel2=RStiel-DRStiel;
      #local Richt=vrotate(vrotate(vrotate(x,Spreiz*z),Knick*y),Bieg*T*x);

      object {
        Cone(P1,RStiel,P2,RStiel2)
        Textur(pigment{BlattGruen1})
      }
      #if (I>1)
        union {
          Cone(P1, RStiel/2, P1+Seit*Rechts*Richt, RStiel/3)
          object {
            Cone(P1, RStiel/2, P1+Seit*Links*Richt, RStiel/3)
            scale <-1,1,1>
          }
          Textur(pigment{BlattGruen1})
        }
      #end
      #if (I>0)
        #local T_=(I+1)/BlattTeile;
        #local Seit_=L*((1-T_)*pow(1-1/BlattTeile,2)-pow(1-T_,3));

        polygon {
          #if (I>1) 5 #else 4 #end
          0
          #if (I>1) Seit*Rechts*vrotate(x,Spreiz*z) #end
          DD+Seit_*Rechts*vrotate(x,Spreiz*z)
          DD 0

          #local W1=degrees(asin((RStiel2-RStiel)/vlength(DD)));
          #if (I>1)
            #local W2=Spreiz-degrees(asin(RStiel/(6*Seit*Rechts)));
          #else
            #local W2=Spreiz;
          #end
          Textur(pigment{
            BlattPig
            scale vlength(DD)/12
            rotate 45*z
            scale <1,1/tan(radians((90-W1-W2)/2)),1>
            rotate (W2-W1-90)/2*z
          })

          rotate Knick*y
          rotate Bieg*T*x
          translate P1
        }

        polygon {
          #if (I>1) 5 #else 4 #end
          0
          #if (I>1) Seit*Links*vrotate(-x,-Spreiz*z) #end
          DD+Seit_*Links*vrotate(-x,-Spreiz*z)
          DD 0

          #if (I>1)
            #local W2=Spreiz-degrees(asin(RStiel/(6*Seit*Links)));
          #end
          Textur(pigment{
            BlattPig
            scale vlength(DD)/12
            rotate -45*z
            scale <1,1/tan(radians((90-W1-W2)/2)),1>
            rotate (W1-W2+90)/2*z
          })

          rotate -Knick*y
          rotate Bieg*T*x
          translate P1
        }

        #local Richt=vrotate(Richt,-Bieg*T_*x);
        #local Knick=degrees(atan2(-Richt.z,Richt.x));
        #local Richt=vrotate(Richt,-Knick*y);
        #local Spreiz=degrees(atan2(Richt.y,Richt.x));
      #end

      #local P1=P2;
      #local RStiel=RStiel2;

      #local I=I+1;
    #end
    rotate degrees(Theta)*x
    rotate degrees(Phi)*y
    translate P
  }
#end


#if (Gross)

  camera {orthographic location -2*z right 2*x up 2*y}
  light_source {<-1,1,-2>*1000 1.5}
  #macro Textur(T) texture{T} #end

  object {Blatt(0,y) translate -x/2}
  object {Blatt(0,y) rotate 28*y translate x/2}
  object {Blatt(-y,y) rotate 56*y translate -x/2}
  object {Blatt(-y,y) rotate 84*y translate x/2}

#else

  #include "dungeon.inc"

  #declare Holzbox = intersection {
    box {
      <-1/2-Ueberlappung+Blattgroesse,0,-1/2-Ueberlappung+Blattgroesse>
      <1/2-Ueberlappung+Blattgroesse,BlockHoehe,1/2-Ueberlappung+Blattgroesse>
    }
    cylinder {
      -y (BlockHoehe+1)*y 0.6
    }
  }

  #macro Ast(P_,D_,R_,N_)
    #local P=P_;
    #local D=D_;
    #local R=R_;
    #local N=N_;
    #local I=0;
    #while(I<N)
      #local I=I+1;
      #if ((I>1) & (rand(Zuf3)<0.13))
        #local D1=Streu(D*0.7,pow(rand(Zuf3),0));
        #local D2=D-D1;
        Ast(P,D1,R*vlength(D1)/vlength(D),N-I)
        Ast(P,D2,R*vlength(D2)/vlength(D),N-I)
      #else#if (inside(Holzbox,P+D))
        #if (I>0)
          Blatt(P,vnormalize(Streu(D,1))*Blattgroesse)
        #end
        #local R2 = R*0.9;
        object {
          Cone(P,R,P+D,R2)
          Textur(pigment {HolzBraun})
        }
        #local P=P+D;
        #local D=Streu(D*0.95,1/2);
        #local R=R2;
      #else
        Blatt(P,vnormalize(D)*Blattgroesse)
        #local I=N;
      #end#end
    #end
  #end

  #declare Krone = union {
    Ast(ErstHoehe*y,<1,0.7,0.9>/30,1/15,30)
  }

  #declare Block = union {
    isosurface {
      function {Stamm(x,y,z)}
      threshold -Aura
      contained_by {box {<-1/2,0,-1/2> <1/2,2,1/2>}}
      max_gradient 30
      Textur(pigment {HolzBraun})
    }
    #local J=0;
    #while (J<360)
      object {Krone rotate J*y}
      #local J=J+90;
    #end
    translate 1/2
  }

  Setze()

#end

