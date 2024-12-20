(*
    Copyright 2006 by Mark Weyer
    Maintenance modifications 2010,2011 by the cuyo developers

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
*)

open Helfer

let pi2 = pi+.pi
let rad = 0.08
let hdicke = rad/.6.0
let rad2 = rad*.rad+.hdicke*.hdicke
let dmin = rad *. (sqrt 2.0)
let dmax = 0.5-.rad
let streurad = 0.3-.dmin
let anzahl = 125
  (* Das ist die Anzahl an Würfen, Münzen gibt es viermal so viele. *)

let rotx w (x,y,z) =
  let c,s = cos w, sin w  in
  x, c*.y-.s*.z , c*.z+.s*.y

let roty w (x,y,z) =
  let c,s = cos w, sin w  in
  c*.x+.s*.z, y , c*.z-.s*.x

let rotz w (x,y,z) =
  let c,s = cos w, sin w  in
  c*.x-.s*.y , c*.y+.s*.x, z

let plus (x1,y1,z1) (x2,y2,z2) = x1+.x2, y1+.y2, z1+.z2


let testdaten (x,y,z,w1,w2) =
  let pi6 = pi/.6.0  in
  let punkt w h = plus (x,y,z) (roty w2 (rotx w1 (roty w (rad,h,0.0))))  in
  let rec rand w = if w>=pi2
    then []
    else (punkt w hdicke)::(punkt w (-.hdicke))::(rand (w+.pi6))  in
  x,y,z,rand 0.0

let kollision (x,y,z,rand) (x',y',z',w1,w2,w3) =
  let dx,dy,dz = x-.x', y-.y', z-.z'  in
  if dx*.dx+.dy*.dy+.dz*.dz < rad2
  then
    let x',y',z',w1,w2 = -.x', -.y', -.z', -.w1, -.w2  in
    List.exists
      (fun p ->
        let x,y,z = rotx w1 (roty w2 (plus (x',y',z') p))  in
        y < hdicke && y > -.hdicke && x*.x+.z*.z < rad*.rad)
      rand
  else false

let kollision muenze muenzen =
  let x,y,z,w1,w2 = muenze  in
  let r2 = x*.x+.z*.z  in
  if y>=(abs_float ((cos w1)*.hdicke))+.(abs_float ((sin w1)*.rad))
      && r2 >= dmin*.dmin  && r2 < dmax*.dmax
    then List.exists (kollision (testdaten muenze)) muenzen
    else true

let kandidaten d (x,y,z,w1,w2) =
  let y' = y-.d*.hdicke  in
  let dw1 = 0.1*.d  in
  [x,y',z,w1,w2] @
  (if w1>=dw1
    then [x,y',z,w1+.dw1,w2;  x,y',z,w1-.dw1,w2;
	  x,y',z,w1,w2+.dw1; x,y',z,w1,w2-.dw1]
    else [x,y',z,dw1,0.0;  x,y',z,dw1,pi/.3.0;  x,y',z,dw1,pi/.1.5;
	  x,y',z,dw1,pi;  x,y',z,dw1,pi/.0.75;  x,y',z,dw1,pi/.0.6]) @
  (if w1>=0.1
    then
      let dxz,dy = rad*.d*.(cos w1), rad*.d*.(sin w1)  in
      [x+.dxz*.(cos w2),y-.dy,z-.dxz*.(sin w2),w1,w2]
    else [])

let fall muenzen ym w r =
  let m = r*.(cos w), ym+.2.0*.(rad+.hdicke), r*.(sin w), 0.0, 0.0  in
  let rec suche d l m = if l>=10
    then m
    else try
      suche d l
	(List.find (fun m' -> not (kollision m' muenzen)) (kandidaten d m))
    with
    | Not_found -> suche (d*.0.5) (l+1) m  in
  suche 1.0 1 m

let muenzen n =
  let rec erweitere ms ym i = prerr_string "."; flush stderr; if i=n
    then ms
    else
      let x,y,z,w1,w2 =
        fall ms ym (Random.float pi2) ((Random.float streurad)+.dmin)  in
      let w1 = if Random.int 2 = 1  then w1  else w1+.pi  in
      let w3 = Random.float 360.0  in
      erweitere
	((x,y,z,w1,w2,w3)::(z,y,-.x,w1,w2+.pi*.0.5,w3)::
	 (-.x,y,-.z,w1,w2+.pi,w3)::(-.z,y,x,w1,w2+.pi*.1.5,w3)::ms)
	(max y ym)  (i+1)  in
  erweitere [] 0.0  0



;;

Random.init 54321;

let muenzen = muenzen anzahl  in

print_string "#declare Rad = "; print_float rad; print_string ";\n";
print_string "#declare HDicke = "; print_float hdicke; print_string ";\n";
print_string "#declare AnzMuenzen = "; print_int (List.length muenzen);
  print_string ";\n\n";
print_string "#declare Muenzen = array[AnzMuenzen+1][6] {\n";
List.iter (fun (x,y,z,w1,w2,w3) ->
    let w1,w2 = w1*.180.0/.pi, w2*.180.0/.pi  in
    print_string "  {"; print_float x; print_string ", "; print_float y;
    print_string ", "; print_float z; print_string ", "; print_float w3;
    print_string ", "; print_float w1; print_string ", "; print_float w2;
    print_string "},\n")
  muenzen;
print_string "  {0,0,0,0,0,0}}\n\n";

prerr_string "\n";

