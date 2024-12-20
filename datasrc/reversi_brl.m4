# -- m4 % > %*.ld; echo ready --
#   Copyright(C) 2005 Bernhard R. Link
#   Maintenance modifications 2005,2006,2011,2014 by the cuyo developers
# 
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
changequote([, ])
define([showingeneratedfile],[$1])
showingeneratedfile([#This is a generated file. Make changes in the .m4 file with the same basename.])
ReversiBRL={
	name = "Reversi"
	author = "brl"
	pics = _0,_1
	greypic = grey
	startpic = lreAlle.xpm
	startdist = "-........-","-........-", "F........F", "F........F","F...-....F","-F%&"
	startdist[[1]] = "F........F","F........F", "F........F", "F........F","F........F","-F%&"
	numexplode = 15
	chaingrass = 1
	toptime = 400
	<< var ro; >>

	grey = {
		pics = lreAlle.xpm
		<< grey ={C*}; >>
	}
dnl
define([paint],[dnl
			if ro != 0 => { 
				ro = 0;
				pos=eval( 3 + othernr ),
				  pos=eval( 6 + othernr ),
				  pos=eval( 9 + othernr ),
				  pos=eval( 12+ othernr ),
				  pos=eval( 15+ othernr );
			} else => {
				pos = thisnr;
			};
			*
])dnl
dnl
define([activate],[kind@($1,$2)=thisname;ro@($1,$2)=1])dnl
define([looklook],[dnl
if kind@($1,$2)==thisname->{$5}dnl
ifelse($6,0,,[else->dnl
if kind@($1,$2)==othername->{dnl
looklook(eval($1 + $3),eval($2 +$4),$3,$4,activate($1,$2)[;]$5,decr($6))}dnl
])dnl
])dnl
dnl
define([look],[if kind@($1,$2)==othername->{dnl
looklook(eval($1+$1),eval($2+$2),$1,$2,activate($1,$2),$3)dnl
};dnl
])dnl
dnl
dnl defcolor(self,other,mypos)
define([defcolor],[dnl
	define([thisname],_$1)dnl
	define([othername],[_]eval( 1- $1))dnl
	define([thisnr],$1)dnl
	define([othernr],eval( 1 - $1))
	thisname = {
		pics = lreAlle.xpm
		<< 
		thisname = {
			paint;
		};
		thisname.land = {
			look(1,1,7)
			look(1,0,7)
			look(1,-1,7)
			look(0,1,16)
dnl			look(0,-1,7)
			look(-1,1,7)
			look(-1,0,7)
			look(-1,-1,7)
		};
		>>
	}
])
	defcolor(0)
	defcolor(1)
}
