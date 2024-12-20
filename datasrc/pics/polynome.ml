(*
   Copyright 2006,2011 by Mark Weyer

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

let drittel = 1.0/.3.0
let zweidrittelpi = pi*.2.0*.drittel

exception Nullpolynom

let loese_0 a = if a=0.0  then raise Nullpolynom  else []
  (* loese_0 a löst a=0 *)

let loese_1 a b = if a=0.0  then loese_0 b  else [-.b/.a]
  (* loese_1 a b löst ax+b=0 *)

let loese_1'_2' a b c d e f =
  (* loese_1'_2' a b c d e f löst das System
       ay + b = 0
       cxy + dx + ey + f = 0 *)
  let ys = try
    loese_1 a b
  with
  | Nullpolynom -> if c=0.0 & d=0.0 & loese_1 e f = []
    then []
    else raise Nullpolynom  in
  List.concat (List.map
    (fun y ->
      let xs = loese_1 (c*.y+.d) (e*.y+.f)  in
      List.map (fun x -> x,y) xs)
    ys)

let loese_2_normiert a b =
  let a' = a*.0.5  in
  let diskriminante = a'*.a'-.b  in
  if diskriminante<0.0
    then []
    else
      let wurzel = sqrt diskriminante  in
      [wurzel-.a'; -.wurzel-.a']

let loese_2 a b c = if a=0.0
  then loese_1 b c
  else loese_2_normiert (b/.a) (c/.a)

let loese_1_2' a b c d e f g =
  (* loese_1_2' a b c d e f g löst das System
       ax + by + c = 0
       dxy + ex + fy + g = 0 *)
  if a=0.0
  then loese_1'_2' b c d e f g
  else
    (* Also x = -b/a*y -c/a *)
    let x_y1 = -.b/.a  in
    let x_y0 = -.c  in
    let ys = loese_2 (d*.x_y1) (d*.x_y0+.e*.x_y1+.f) (e*.x_y0+.g)  in
    List.map
      (fun y -> x_y1*.y +. x_y0, y)
      ys

let loese_2'_2' a b c d e f g h =
  (* loese_2'_2' a b c d e f g h löst das System
       axy + bx + cy + d = 0
       exy + fx + gy + h = 0 *)
  if a=0.0
  then loese_1_2' b c d e f g h
  else if e=0.0
    then loese_1_2' f g h a b c d
    else
      (* Die erste Gleichung ist x*(ay+b)=-(cy+d)
         Zunächst behandeln wir den Sonderfall ay+b=0 *)
      let y_sonder = -.b/.a  in  (* Wir wissen schon a<>0.0 *)
      let loes_sonder = if c*.y_sonder+.d = 0.0
      then (* Erste Gleichung tatsächlich erfüllt *)
        List.map (fun x -> x,y_sonder)
          (loese_1 (e*.y_sonder+.f) (g*.y_sonder+.h))
      else []  in
      (* Sonst können wir x=-(cy+d)/(ay+b) substituieren.
         Wir erweitern die zweite Gleichung mit ay+b und erhalten
           - e(cy+d)y - f(cy+d) + gy(ay+b) + h(ay+b) = 0 *)
      let ys = loese_2 (g*.a-.e*.c) (g*.b+.h*.a-.e*.d-.f*.c) (h*.b-.f*.d)  in
      loes_sonder @ List.map (fun y -> -.(c*.y+.d)/.(a*.y+.b), y) ys

let loese_3 a b c d = if a=0.0
  then loese_2 b c d
  else
    let e,f,g = b/.(a*.3.0), c/.a, d/.a  in
      (* Jetzt: x^3 + 3ex^2 + fx + g = 0
         Substitution: x=y-e
                       x reell <=> y reell *)
    let h,i = f*.drittel-.e*.e, g*.0.5-.(f*.0.5-.e*.e)*.e  in
      (* Jetzt: y^3 + 3hy + 2i = 0 *)
    if i=0.0
      then
        if h>0.0
          then [-.e]
          else
            let y1=sqrt (h*.(-3.0))  in
            [-.e; y1-.e; -.y1-.e]
      else
        (* Substitution: y=z-h/z
                         y reell <=> z reell oder |z|^2 = -h
                                                  (und dann y=2*Re(z)) *)
        let j = -.h*.h*.h  in
          (* Jetzt: z^3 + 2i + j/z^3 = 0
             Substituiere: z=t^1/3
                           eins von drei z reell <=> t reell
                           |z|^2 = -h <=> |t|^2 = j
             Dann: t^2 + 2it + j = 0 *)
        let i2 = i*.i  in
        if i2<=j
          then (* Für t gibt es keine reelle Lösung (außer im Spezialfall
                  i^2=j). Dafür gibt es drei reelle Lösungen für y,
                  (also natürlich alle über die "|t|^2=j"-Schiene). *)
            let alpha = (atan2 (sqrt (j-.i2)) (-.i))*.drittel  in
              (* t=(j^1/2, 3*alpha) in Polardarstellung *)
            let k=2.0*.(sqrt (-.h))  in    (* k=2*|z| *)
            [k*.(cos alpha)-.e; k*.(cos (alpha+.zweidrittelpi))-.e;
              k*.(cos (alpha-.zweidrittelpi))-.e]
          else (* Jetzt ist |t|^2=j unmöglich. Also wird nur das reelle z
                  weiterverfolgt. *)
            let t = sqrt(i2-.j)-.i  in
            let z = if t<0.0
              then -.((-.t) ** drittel)
              else t ** drittel  in
            [z-.h/.z-.e]

let loese_4 a b c d e = if a=0.0
  then loese_3 b c d e
  else
    let f,g,h,i = b/.(a*.4.0), c/.a, d/.a, e/.a  in
    (* Jetzt: x^4 + 4fx^3 + gx^2 + hx + i = 0
       Substitution: x=y-f *)
    let j,k,l = -6.0*.f*.f+.g, (8.0*.f*.f-.2.0*.g)*.f+.h,
      ((-3.0*.f*.f+.g)*.f-.h)*.f+.i  in
    (* Jetzt: y^4 + jy^2 + ky + l = 0 *)
    if k=0.0
      then (* Substitution y=z^1/2, also dann z^2 + jz + l = 0 *)
        let ze = loese_2_normiert j l  in
        List.concat (List.map
          (function z -> if z>=0.0
            then let y=sqrt z  in [y-.f;-.y-.f]
            else [])
          ze)
      else if l=0.0
        then (-.f)::(List.map (function y -> y-.f)
          (loese_3 1.0 0.0 j k))
        else
          (* Ziel: Faktorisierung in zwei quadratische Polynome.
             Das wären dann (y^2 + my + l/n) und (y^2 - my + n).
             Da nichtreelle Nullstellen paarweise konjugiert auftreten,
             ist das auf jeden Fall mit rellem m und n machbar.
             Wir erhalten das System:
               j = n-m^2+l/n  und  k = mn-ml/n
             m=0 ist ausgeschlossen, da sonst k=0, also unter
             Äquivalenzumformungen:
               m^2+j = n+l/n  und  k/m = n-l/n
               m^2+j+k/m = 2n und  m^2+j-k/m = 2l/n
               4l = m^4 + 2jm^2 + j^2 - k^2/m^2  und  n = (m^2+j+k/m)/2 *)
          let m2 = List.find (function m2 -> m2>0.0)
            (loese_3 1.0 (2.0*.j) (j*.j-.4.0*.l) (-.k*.k))  in
          let m = sqrt m2  in
          let n = (m2+.j+.k/.m)/.2.0  in
          List.map (fun y -> y-.f)
            ((loese_2_normiert m (l/.n)) @ (loese_2_normiert (-.m) n))

let rec loese_2_2 a20 a11 a02 a10 a01 a00 b20 b11 b02 b10 b01 b00 =
  if a20=0.0
  then if b20=0.0
    then if a02=0.0 & b02=0.0
      then loese_2'_2' a11 a10 a01 a00 b11 b10 b01 b00
      else List.map (fun (x,y) -> y,x)
        (loese_2_2 a02 a11 a20 a01 a10 a00 b02 b11 b20 b01 b10 b00)
    else loese_2_2 b20 b11 b02 b10 b01 b00 a20 a11 a02 a10 a01 a00
  else
    let c11 = a11/.a20  in
    let c02 = a02/.a20  in
    let c10 = a10/.a20  in
    let c01 = a01/.a20  in
    let c00 = a00/.a20  in
    (* Also ist die erste Gleichung x^2 + (c11y+c10)x + (c02y^2+c01y+c00) = 0
       Die Lösung ist x = d1y + d0 +- w mit w = sqrt (e2y^2 + e1y + e0) *)
    let d1 = -.c11/.2.0  in
    let d0 = -.c10/.2.0  in
    let e2 = d1*.d1 -. c02  in
    let e1 = 2.0*.d1*.d0 -. c01  in
    let e0 = d0*.d0 -. c00  in
    (* Es folgt x^2 = f2y^2 + f1y + f0 +- g1yw +- g0w *)
    let f2 = d1*.d1 +. e2  in
    let f1 = 2.0*.d1*.d0 +. e1  in
    let f0 = d0*.d0 +. e0  in
    let g1 = 2.0*.d1  in
    let g0 = 2.0*.d0  in
    (* Damit wird die zweite Gleichung zu h2y^2 + h1y + h0 = +- i1yw +- i0w *)
    let h2 = b20*.f2 +. b11*.d1 +. b02  in
    let h1 = b20*.f1 +. b11*.d0 +. b10*.d1 +. b01  in
    let h0 = b20*.f0 +. b10*.d0 +. b00  in
    let i1 = b20*.g1 +. b11  in
    let i0 = b20*.g0 +. b10  in
    (* Das quadrieren wir. Wegen des +- bleibt die Lösungsmenge gleich. *)
    let ys = loese_4
      (h2*.h2 -. i1*.i1*.e2)
      (2.0*.h2*.h1 -. i1*.i1*.e1 -. 2.0*.i1*.i0*.e2)
      (h1*.h1 +. 2.0*.h2*.h0 -. i1*.i1*.e0 -. i0*.i0*.e2 -. 2.0*.i1*.i0*.e1)
      (2.0*.h1*.h0 -. i0*.i0*.e1 -. 2.0*.i1*.i0*.e0)
      (h0*.h0 -. i0*.i0*.e0)  in
    List.concat (List.map
      (fun y ->
        (* Kommt diese Lösung von der +w oder von der -w Variante?
           Um das herauszufinden testen wir, welches entsprechende x die
           zweite Gleichung besser löst. Nicht, welche genau löst, denn
           (im Gegensatz zu obigen Tests von Koeffizienten auf 0) muß mit
           numerischen Ungenauigkeiten gerechnet werden. *)
        let w2 = e2*.y*.y +. e1*.y +. e0  in
        if w2<0.0
        then []
        else
          let w = sqrt w2  in
          let x1,x2 = d1*.y +. d0 +. w, d1*.y +. d0 -. w  in
          let wert1 = b20*.x1*.x1 +. b11*.x1*.y +. b02*.y*.y
            +. b10*.x1 +. b01*.y +. b00  in
          let wert2 = b20*.x2*.x2 +. b11*.x2*.y +. b02*.y*.y
            +. b10*.x2 +. b01*.y +. b00  in
          if abs_float wert1 > abs_float wert2
          then [x2,y]
          else [x1,y])
      ys)

