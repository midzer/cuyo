(*
   Copyright 2006,2010,2011 by Mark Weyer

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

let eps = 0.000001
  (* Diese Nähe (in der Parametrisierung von 0 bis 1) zum Endpunkt einer
     Strecke reicht für Gleichheit. *)

let laengen_fehler = 1.0001
  (* Sobald die Dreiecksungleichung höchstens um diesen Faktor unscharf ist,
     wird bei der Längenberechnung nicht noch weiter aufgeteilt. *)

open Farbe
open Graphik
open Helfer

(*
   Zuerst ein paar Hilfsdefinitionen
*)

type 'a lazyval = Unknown of (unit -> 'a) | Known of 'a

let set_lazy f = ref (Unknown f)
let get_lazy l = match (!l)  with
  | Unknown f -> let v=f ()  in (l:=Known v; v)
  | Known v -> v

let xor a b = (a || b) && (not (a && b))

let list_min f (h::t) = List.fold_left
  (function bisher -> function x -> min bisher (f x))
  (f h)
  t
let list_max f (h::t) = List.fold_left
  (function bisher -> function x -> max bisher (f x))
  (f h)
  t
let list_sum f = List.fold_left
  (function bisher -> function x -> bisher+.(f x))
  0.0

let skalar (x0,y0) (x,y) (x',y') = (x-.x0)*.(x'-.x0) +. (y-.y0)*.(y'-.y0)
let abstand p1 p2 = sqrt (skalar p1 p2 p2)
let richtung (x1,y1) (x2,y2) = atan2 (y2-.y1) (x2-.x1)
  (* Achtung: Die Punkte müssen verschieden sein! *)
let rec bereinige_winkel w = if w<0.0
  then bereinige_winkel (w+.2.0*.pi)
  else if w>=2.0*.pi
    then bereinige_winkel (w-.2.0*.pi)
    else w
let kreispunkt (x,y) r w = x+.r*.(cos w), y+.r*.(sin w)

let skaliere_punkt t (x,y) = t*.x, t*.y
let addiere_punkte (x,y) (x',y') = x+.x', y+.y'
let verschiebe_punkt dx dy = addiere_punkte (dx,dy)
let drehe_punkt winkel (x,y) =
  let c = cos winkel  in
  let s = sin winkel  in
  (c*.x-.s*.y, s*.x+.c*.y)
let spiegel_punkt (x,y) = -.x, y

let spline p1 p1' p2' p2 t =
  let u = 1.0-.t  in
  addiere_punkte
    (addiere_punkte
      (skaliere_punkt (u*.u*.u) p1)
      (skaliere_punkt (t*.t*.t) p2))
    (skaliere_punkt (3.0*.t*.u)
      (addiere_punkte
        (skaliere_punkt u p1')
        (skaliere_punkt t p2')))

let spline_polynom_ableitung x1 x1' x2' x2 t =
  3.0*.(x1'-.x1+.t*.(2.0*.(x2'-.2.0*.x1'+.x1)+.t*.(x2-.3.0*.(x2'-.x1')-.x1)))

let spline_ableitung (x1,y1) (x1',y1') (x2',y2') (x2,y2) t =
  spline_polynom_ableitung x1 x1' x2' x2 t,
  spline_polynom_ableitung y1 y1' y2' y2 t

type topologischer_ort = | Aussen | Innen | Rand

let winkel_interval w1 w2 w vorwaerts =
  let w1,w2,w =
    bereinige_winkel w1, bereinige_winkel w2, bereinige_winkel w  in
  if w=w1 || w=w2
    then Rand
    else if w1=w2
      then Aussen
      else if xor (xor (w<w1) (w<w2)) (xor (w1<w2) vorwaerts)
        then Innen
        else Aussen




(*
   Der wichtige Typ fürs Interface
*)

type linie =
  | Strecke of (punkt * punkt)
  | Kreis of (punkt * float)
  | Bogen of (punkt * float * bool * float * float)
  | Spline of (punkt * punkt * punkt * punkt)

let linie_rueckwaerts = function
  | Strecke (p1,p2) -> Strecke (p2,p1)
  | Kreis k -> Kreis k
  | Bogen (p,r,g,w1,w2) -> Bogen (p,r,not g,w2,w1)
  | Spline (p1,p1',p2',p2) -> Spline (p2,p2',p1',p1)

let verschiebe_linie dx dy = function
  | Strecke (p1,p2) -> Strecke
    (verschiebe_punkt dx dy p1, verschiebe_punkt dx dy p2)
  | Kreis (p,r) -> Kreis (verschiebe_punkt dx dy p, r)
  | Bogen (p,r,g,w1,w2) -> Bogen
    (verschiebe_punkt dx dy p, r,g,w1,w2)
  | Spline (p1,p1',p2',p2) -> Spline
    (verschiebe_punkt dx dy p1, verschiebe_punkt dx dy p1',
    verschiebe_punkt dx dy p2', verschiebe_punkt dx dy p2)

let drehe_linie winkel = function
  | Strecke (p1,p2) -> Strecke (drehe_punkt winkel p1, drehe_punkt winkel p2)
  | Kreis (p,r) -> Kreis (drehe_punkt winkel p, r)
  | Bogen (p,r,g,w1,w2) -> Bogen
    (drehe_punkt winkel p, r, g, w1+.winkel, w2+.winkel)
  | Spline (p1,p1',p2',p2) -> Spline
    (drehe_punkt winkel p1, drehe_punkt winkel p1',
    drehe_punkt winkel p2', drehe_punkt winkel p2)

let skaliere_linie faktor = function
  | Strecke (p1,p2) ->
    Strecke (skaliere_punkt faktor p1, skaliere_punkt faktor p2)
  | Kreis (p,r) -> Kreis (skaliere_punkt faktor p, r*.faktor)
  | Bogen (p,r,g,w1,w2) ->
    Bogen (skaliere_punkt faktor p, r*.faktor, g, w1, w2)
  | Spline (p1,p1',p2',p2) -> Spline
    (skaliere_punkt faktor p1, skaliere_punkt faktor p1',
    skaliere_punkt faktor p2', skaliere_punkt faktor p2)

let spiegel_linie = function
  | Strecke (p1,p2) -> Strecke (spiegel_punkt p1, spiegel_punkt p2)
  | Kreis (p,r) -> Kreis (spiegel_punkt p,r)
  | Bogen (p,r,g,w1,w2) -> Bogen (spiegel_punkt p,r, not g, pi-.w1, pi-.w2)
  | Spline (p1,p1',p2',p2) -> Spline
    (spiegel_punkt p1, spiegel_punkt p1', spiegel_punkt p2', spiegel_punkt p2)

let abstand_linie linie p =
  (* Spline ist nicht erlaubt! *)
  match linie with
  | Strecke (p1,p2) ->
    if p1=p2
      then abstand p p1
      else
        let x1,y1 = p1  in
        let x2,y2 = p2  in
        let x0,y0 = p  in
        let skalar = skalar p1  in
        let radial = (skalar p2 p)/.(skalar p2 p2)  in
        if radial < 0.0
          then abstand p p1
          else if radial > 1.0
            then abstand p p2
            else
              let dx = x0-.x1-.radial*.(x2-.x1)  in
              let dy = y0-.y1-.radial*.(y2-.y1)  in
              sqrt (dx*.dx +. dy*.dy)
  | Kreis (p0,r) -> abs_float (r-.(abstand p p0))
  | Bogen (p0,r,g,w1,w2) ->
    if p=p0
      then r
      else if (winkel_interval w1 w2 (richtung p0 p) g)=Innen
        then abs_float (r-.(abstand p p0))
        else min
          (abstand p (kreispunkt p0 r w1))
          (abstand p (kreispunkt p0 r w2))

exception Endpunkt

let schneidet_strecke p1 p2 p3 p4 =
    (* Voraussetzung: p1 verschieden von p2 *)
  if p3=p4
    then false
    else
      let (x1,y1),(x2,y2),(x3,y3),(x4,y4) = p1,p2,p3,p4  in
      (*
         Wir lösen das System t*p1+(1-t)*p2 = u*p3+(1-u)*p4,
         also t*(p1-p2)+u*(p4-p3) = p4-p2
      *)
      let a11,a12,a21,a22 = x1-.x2, x4-.x3, y1-.y2, y4-.y3  in
      let det = a11*.a22 -. a12*.a21  in
      if det=0.0
        then if a11*.(y3-.y1) = a21*.(x3-.x1)
            (* Die Strecken sind parallel, aber sind sie auch kolinear? *)
          then
              (* Jetzt kommt es auf die Anordnung an *)
            let z1,z2,z3,z4 =
              if x1=x2  then y1,y2,y3,y4  else x1,x2,x3,x4  in
            let z5,z6 = min z1 z2, max z1 z2  in
            if (z3<z5 && z4<z5) || (z3>z6 && z4>z6)
                (* Sind die Strecken schnittfrei? *)
              then false
              else raise Endpunkt
          else false
        else
          let b1,b2 = x4-.x2, y4-.y2  in
          let t,u = (b1*.a22 -. b2*.a12)/.det, (b2*.a11 -. b1*.a21)/.det  in
          if 0.0<=t && t<=1.0 && 0.0<=u && u<=1.0
            then if (t > -.eps && t<eps) || (t>1.0-.eps && t<1.0+.eps)
                || (u > -.eps && u<eps) || (u>1.0-.eps && u<1.0+.eps)
              then raise Endpunkt
              else true
            else false

let schnitte_spline p1 p2 p3 p3' p4' p4 =
    (* Zählt die Schnitte des Splines (p3,p3',p4',p4) mit der Strecke (p1,p2).
       Die Anzahl berücksichtigt Vielfachheiten.
       Voraussetzung: p1 verschieden von p2 *)
  (* Wir wollen lösen:
     (1-t)^3p3 + 3t(1-t)^2p3' + 3t^2(1-t)p4' + t^3p4 = (1-u)p1 + up2
     Das ist:
     t^3(p4-3p4'+3p3'-p3) + 3t^2(p4'-2p3'+p3) + 3t(p3'-p3) + p3 = u(p2-p1) + p1
  *)
  let (x1,y1),(x2,y2),(x3,y3),(x3',y3'),(x4',y4'),(x4,y4)
    = p1,p2,p3,p3',p4',p4  in
  let dx,dy = x2-.x1, y2-.y1  in
  (* Wir wollen durch dx teilen dürfen,
     also notfalls alles an der Diagonale spiegeln. *)
  let x1,y1,x2,y2,x3,y3,x3',y3',x4',y4',x4,y4,dx,dy =
    if abs_float dx > abs_float dy
    then x1,y1,x2,y2,x3,y3,x3',y3',x4',y4',x4,y4,dx,dy
    else y1,x1,y2,x2,y3,x3,y3',x3',y4',x4',y4,x4,dy,dx  in
  (* Wir haben schon d=p2-p1. Mit d3=p3'-p3 und d'=p4'-p3' wollen wir lösen:
     t^3(p4-3d'-p3) + 3t^2(d'-d3) + 3td3 + p3 = ud + p1 *)
  let dx3,dy3,dx',dy' = x3'-.x3, y3'-.y3, x4'-.x3', y4'-.y3'  in
  let uf = dy/.dx  in
  let c3x,c2x,c1x,c0x = x4-.3.0*.dx'-.x3, 3.0*.(dx'-.dx3), 3.0*.dx3, x3-.x1  in
  (* Es folgt u=(c3xt^3 + c2xt^2 + c1xt + c0x)/dx.
     Also bleibt zu lösen:
     t^3(y4-3dy'-y3 - ufc3x)
     + t^2(3(dy'-dy3) - ufc2x)
     + t(3dy3 - ufc1x)
     + y3-y1 - ufc0x
     = 0 *)
  try
    let ts = Polynome.loese_3
      (y4-.3.0*.dy'-.y3-.uf*.c3x)
      (3.0*.(dy'-.dy3)-.uf*.c2x)
      (3.0*.dy3-.uf*.c1x)
      (y3-.y1-.uf*.c0x)  in
    List.fold_left (fun anzahl -> fun t ->
        if t<0.0 || t>1.0
        then anzahl
        else
          let u = (c0x+.t*.(c1x+.t*.(c2x+.t*.c3x)))/.dx  in
          if u<0.0 || u>1.0
          then anzahl
          else if t=0.0 || t=1.0 || u=0.0 || u=1.0
            then raise Endpunkt
            else anzahl+1)
      0  ts
  with
  | Polynome.Nullpolynom ->
    (* Alle sechs Punkte kolinear. Wir können auf die x-Achse projizieren.
       Als nächstes brauchen wir die Ausdehnung des Splines. *)
    let xmin,xmax = try
      let extremstellen = Polynome.loese_2
        (x4-.3.0*.dx'-.x3)
        (2.0*.(dx'-.dx3))
        dx3  in
      let randwerte = List.map
        (fun t -> x3+.t*.(c1x+.t*.(c2x+.t*.c3x)))
        (0.0::1.0::List.filter (fun t -> t>0.0 && t<1.0) extremstellen)  in
      list_min id randwerte,
      list_max id randwerte
    with
    | Polynome.Nullpolynom -> (* Der Spline ist ein Punkt. *)
      x3,x3  in
    if (x1<xmin && x2<xmin) || (x1>xmax && x2>xmax)
    then 0
    else raise Endpunkt



let schneidet_linie linie p1 p2 = if p1=p2
  (*
     Gibt es eine ungerade Anzahl an Schnittpunkten der Linie linie
     mit der Strecke (p1,p2)?
     Sonderfälle:
       Wenn die Linie oder die Strecke zu einem Punkt entartet ist,
         darf die Antwort immer auch false sein.
       Wenn sonst einer der Schnittpunkte ein Endpunkt der Linie oder
       der Strecke ist, muß Endpunkt geraist werden.
  *)
  then false
  else match linie  with
    | Strecke (p3,p4) -> schneidet_strecke p1 p2 p3 p4
    | Kreis (p,r) ->
      let r1,r2 = abstand p p1, abstand p p2  in
      if r1=r || r2=r
        then raise Endpunkt
        else xor (r1<r) (r2<r)
    | Bogen (p,r,g,w1,w2) -> if r=0.0
      then false
      else
        let (x1,y1),(x2,y2),(x,y) = p1,p2,p  in
        (*
           Zuerst berechnen wir die Schnittpunkte mit dem Kreis:
           d^2(t*p1+(1-t)*p2, p) = r^2
        *)
        let dx,dy,dx',dy' = x1-.x2, y1-.y2, x2-.x, y2-.y  in
        let a,b,c =
          dx*.dx+.dy*.dy,  dx*.dx'+.dy*.dy',  dx'*.dx'+.dy'*.dy'-.r*.r  in
        let a',b' = b/.a, c/.a  in
        let disk = a'*.a'-.b'  in
        if disk < 0.0
          then false (* Wir schneiden nicht mal den Kreis! *)
          else
            let t1,t2 = let wurzel = sqrt disk  in -.wurzel-.a', wurzel-.a'  in
            let schneidet t =
              if t>1.0 || t<0.0
                then false
                else
                  let u=1.0-.t  in
                  match winkel_interval w1 w2
                    (richtung (t*.x1+.u*.x2, t*.y1+.u*.y2) p) g  with
		  | Rand -> raise Endpunkt
		  | Innen -> if t=1.0 || t=0.0
                    then raise Endpunkt
                    else true
		  | Aussen -> false  in
            xor (schneidet t1) (schneidet t2)
    | Spline (p3,p3',p4',p4) -> (schnitte_spline p1 p2 p3 p3' p4' p4) land 1=1

exception Drauf

let windung_strecke' w =
  if w>=pi
    then if w=pi
      then raise Drauf
      else w-.2.0*.pi
    else if w <= -.pi
      then if w = -.pi
        then raise Drauf
        else w+.2.0*.pi
      else w

let windung_strecke p p1 p2 =
    (* Voraussetzung: p verschieden von p1,p2 *)
  windung_strecke' ((richtung p p2)-.(richtung p p1))

let windung_spline p p1 p1' p2' p2 p3 =
  (* p3 ist so, daß p nicht auf dem Zug p1p3p2 liegt, außer p=p1 oder p=p2. *)
  let zugwindung = windung_strecke p p1 p3 +. windung_strecke p p3 p2  in
  let schnitte p' =
    (* Anzahl der Schnitte der Geraden p'p mit dem Rundweg Spline+p2p3p1. *)
    schnitte_spline p p' p1 p1' p2' p2
    + (if schneidet_strecke p p' p2 p3  then 1  else 0)
    + (if schneidet_strecke p p' p3 p1  then 1  else 0)  in
  let x0,y0 = List.fold_left
    (fun (x,y) -> fun (x',y') -> min x x', min y y')
    p  [p1;p1';p2';p2;p3]  in
  let schnitte =
    (* Wir probieren bei exception Endpunkt mehrere p' aus, bis wir sicher sind,
       daß einmal davon der Endpunkt p ist und nicht etwa p1, p2 oder p3. *)
    try schnitte (x0-.1.0,y0-.1.0)
    with Endpunkt ->
      try schnitte (x0-.2.0,y0-.1.0)
      with Endpunkt ->
        try schnitte (x0-.3.0,y0-.1.0)
        with Endpunkt ->
          try schnitte (x0-.4.0,y0-.1.0)
          with Endpunkt -> raise Drauf  in
  if schnitte land 1 = 0
  then zugwindung
  else zugwindung+.2.0*.pi


let windung_linie linie p =
  match linie  with
  | Strecke (p1,p2) ->
    if p=p1 || p=p2
      then raise Drauf
      else windung_strecke p p1 p2
  | Kreis (p0,r) ->
    let d=abstand p p0  in
    if d<r  then 2.0*.pi  else if d>r  then 0.0  else raise Drauf
  | Bogen (p0,r,g,w1,w2) ->
    let w1,w2 = if g  then w1,w2  else w2,w1  in
    let d=abstand p p0  in
    if d=r
      then if p=p0
        then raise Drauf
        else if (winkel_interval w1 w2 (richtung p0 p) true) = Innen
          then raise Drauf
          else ()
      else ();
    let w=
      (richtung p (kreispunkt p0 r w2)) -.
      (richtung p (kreispunkt p0 r w1))  in
    let w = if d>r
      then windung_strecke' w
      else bereinige_winkel w  in
    if g  then w  else -.w
  | Spline (p1,p1',p2',p2) ->
    if p=p1 || p=p2
      then raise Drauf
      else
        let (x,y),(x1,y1),(x2,y2) = p,p1,p2  in
        let dx,dy = x2-.x1, y2-.y1  in
        let xm,ym = (x1+.x2)/.2.0, (y1+.y2)/.2.0  in
        let p3a = xm+.dy, ym-.dx  in
        let p3b = xm-.dy, ym+.dx  in
        let p3 = if abstand p p3a > abstand p p3b  then p3a  else p3b  in
        windung_spline p p1 p1' p2' p2 p3



let windung_drin windungszahl =
  let w = truncate (floor (windungszahl/.(2.0*.pi)+.0.5))  in
  (w land 1)<>0



type polygon = linie list

let verschiebe_polygon dx dy = List.map (verschiebe_linie dx dy)
let drehe_polygon w = List.map (drehe_linie (w*.pi/.180.0))
let skaliere_polygon f = List.map (skaliere_linie f)
let spiegel_polygon = List.map spiegel_linie



module type Malmethode = sig

  type polygon'

  val konvertiere_polygon : polygon -> polygon'
  val punkt_auf_polygon_relativ : polygon' -> float -> punkt * float option
  val rueckwaerts: polygon' -> polygon'

  type vektording =
    | Strich of (farbe * polygon' list)
    | Dicker_Strich of (farbe * float * polygon' list)
    | Flaechen of (farbe array * (polygon' * int * int option) list)

  val flaeche : farbe -> polygon' list -> vektording
  val pixel_zu_dingen : farbe option -> pixelbild -> vektording list

  val map_vektordinge: (linie -> linie) -> vektording list -> vektording list
  val verschiebe_dinge: float -> float -> vektording list -> vektording list
  val drehe_dinge: float -> vektording list -> vektording list
  val skaliere_dinge: float -> vektording list -> vektording list
  val spiegel_dinge: vektording list -> vektording list

  type vektorbild

  val erzeuge_vektorbild : vektording list -> vektorbild
  val male: vektorbild -> float -> bildchen -> bildchen

end



type laengen_baum =
  | Blatt of float
  | Nichtblatt of (laengen_baum * float * laengen_baum * float)
    (* erster float: Kurvenparameter in der Mitte
       zweiter float: Gesamtlänge *)

let erstelle_laengen_baum f tmin tmax =
  let rec teile t1 p1 t2 p2 l =
    let t3 = (t1+.t2)*.0.5  in
    let p3 = f t3  in
    let l1,l2 = abstand p1 p3, abstand p3 p2  in
    let (b1,l1'),(b2,l2') = if (l1+.l2)/.l < laengen_fehler
      then (Blatt l1, l1), (Blatt l2, l2)
      else teile t1 p1 t3 p3 l1, teile t3 p3 t2 p2 l2  in
    let l' = l1'+.l2'  in
    Nichtblatt (b1,t3,b2,l'), l'  in
  let pmin,pmax = f tmin, f tmax  in
  fst (teile tmin pmin tmax pmax (abstand pmin pmax))

let erstelle_laengen_baum l = match l  with
  | Strecke (p1,p2) -> Blatt (abstand p1 p2)
  | Bogen (p,r,g,w1,w2) -> Blatt (r*.(abs_float (w1-.w2)))
  | Spline (p1,p1',p2',p2) ->
    erstelle_laengen_baum (spline p1 p1' p2' p2) 0.0 1.0

let laenge b = match b  with
  | Blatt l -> l
  | Nichtblatt (b1,t,b2,l) -> l

let rec suche_laenge_absolut l0 t1 t2 b = match b  with
  | Blatt l -> t1+.(t2-.t1)*.l0/.l
  | Nichtblatt (b1,t3,b2,l3) ->
    let l1 = laenge b1  in
    if l0<=l1
      then suche_laenge_absolut l0 t1 t3 b1
      else suche_laenge_absolut (l0-.l1) t3 t2 b2



module Methode_Daten_abstrakt = struct

  type polygon' = (linie * laengen_baum lazyval ref) list * bool
    (* Der bool steht für rückwärts *)

  let rueckwaerts (p,r) = p, not r

  let erzeuge_laenge l = l, set_lazy (function u -> erstelle_laengen_baum l)

  let konvertiere_polygon pol = List.map erzeuge_laenge pol, false

  let punkt_auf_polygon_relativ (p,r) t =
    let l = list_sum (function l,b -> laenge (get_lazy b)) p  in
    let l0 = if r  then (1.0-.t)*.l  else t*.l  in
    let rec suche l ((li,b)::t) =
      let b' = get_lazy b  in
      let lh = laenge b'  in
      if l<=lh
        then li, suche_laenge_absolut l 0.0 1.0 b'
        else suche (l-.l0) t  in
    let li,t = suche l0 p  in
    let p,w = match li  with
      | Strecke (p1,p2) ->
        addiere_punkte (skaliere_punkt (1.0-.t) p1) (skaliere_punkt t p2),
        if p1=p2  then None  else Some (richtung p1 p2)
      | Bogen (p,r,g,w1,w2) ->
        let w = w1+.t*.(w2-.w1)  in
        kreispunkt p r w,
        Some (w+.pi*.(if g  then 0.5  else -0.5))
      | Spline (p1,p1',p2',p2) ->
        spline p1 p1' p2' p2 t,
          let dx,dy = spline_ableitung p1 p1' p2' p2 t  in
          if dx=0.0 && dy=0.0  then None  else Some (atan2 dy dx)  in
    match w  with
    | None -> p,None
    | Some w -> p, Some ((if r  then w+.pi  else w)*.180.0/.pi)



  type polygon'' = linie list * bool

  let konvertiere_polygon' (p,r) = List.map fst p, r

  let map_polygon' f (p,r) =
    List.map
      (function l,b -> erzeuge_laenge (f l))
      p,
    r



  type vektording =
    | Strich of (farbe * polygon' list)
    | Dicker_Strich of (farbe * float * polygon' list)
    | Flaechen of (farbe array * (polygon' * int * int option) list)

  let flaeche f ps = Flaechen ([|f|], List.map (function p -> p,0,None) ps)

  type pzd_pos =
  | PZD_Punkt
  | PZD_Innen
  | PZD_Aussen

  let pixel_zu_dingen auslass bild =
    let breite,hoehe,pixel = bild  in
    if breite=0 || hoehe=0
    then []
    else
      let palette,farbindex = extrahiere_farben bild  in
        (* Ab jetzt sind Farben immer nur Indices in die palette. *)
      let auslass = match auslass with
      | None -> None
      | Some f ->
        let i = FarbMap.find f farbindex  in
        if f=palette.(i)  then Some i  else None  in
      let pos_zu_punkt (x,y) = float_of_int x, float_of_int (hoehe-y)  in
      let pos_zu_farbe (x,y) = if x>=0 && x<breite && y>=0 && y<hoehe
        then Some (FarbMap.find pixel.(y).(x) farbindex)
        else None  in
      let rand = Array.make (Array.length palette) []  in
      let binnen = Array.init (Array.length palette)
        (fun i -> Array.make i [])  in
      let reihe pos =
        let rec doit i start innen aussen =
            (* pos : int -> pzd -> (int*int) wandelt i in eine Position um.
               i : int ist der Schleifenindex.
               start : punkt ist der Startpunkt der Kante, deren Ende gerade
                 gesucht wird.
               innen : farbe option und aussen : farbe option sind die Farben,
                 die diese Kante trennt trennt.
            *)
          let innen' = pos_zu_farbe (pos i PZD_Innen)  in
          let aussen' = pos_zu_farbe (pos i PZD_Aussen)  in
          if (innen',aussen')=(innen,aussen)
          then doit (i+1) start innen aussen
          else
            (let ende = pos_zu_punkt (pos i PZD_Punkt)  in
            let innen = if innen=auslass  then None else innen  in
            let aussen = if aussen=auslass  then None else aussen  in
            (match innen,aussen with
            | (Some f1, Some f2) -> if f1=f2
              then ()
              else if f1<f2
                then binnen.(f2).(f1) <-
                  (Strecke (start,ende))::binnen.(f2).(f1)
                else binnen.(f1).(f2) <-
                  (Strecke (ende,start))::binnen.(f1).(f2)
            | (Some f, None) -> rand.(f) <- (Strecke (ende,start))::rand.(f)
            | (None, Some f) -> rand.(f) <- (Strecke (start,ende))::rand.(f)
            | (None,None) -> ());
            if (innen',aussen') <> (None,None)
            then doit (i+1) ende innen' aussen')  in
        doit 1 (pos_zu_punkt (pos 0 PZD_Punkt))
          (pos_zu_farbe (pos 0 PZD_Innen))
          (pos_zu_farbe (pos 0 PZD_Aussen))  in
      for j = 0 to hoehe do
        reihe (fun i -> fun pzd -> (i, j - if pzd=PZD_Aussen then 1 else 0))
      done;
      for j = 0 to breite do
        reihe (fun i -> fun pzd -> ((j - if pzd=PZD_Innen then 1 else 0), i))
      done;
      let einfach_grenzen = array_foldi
        (fun grenzen -> fun farbe -> fun grenze -> if grenze=[]
          then grenzen
          else (konvertiere_polygon grenze,farbe,None)::grenzen)
        []  rand  in
      let grenzen = array_foldi
        (fun grenzen -> fun farbe1 -> array_foldi
          (fun grenzen -> fun farbe2 -> fun grenze -> if grenze=[]
            then grenzen
            else (konvertiere_polygon grenze,farbe1,Some farbe2)::grenzen)
          grenzen)
        einfach_grenzen
        binnen  in
      [Flaechen (palette,grenzen)]



  type vektording' =
    | Strich' of (farbe * polygon'' list)
    | Dicker_Strich' of (farbe * float * polygon'' list)
    | Flaechen' of (farbe array * (polygon'' * int * int option) list)

  type vektorbild = vektording' list

  let erzeuge_vektorbild vektordinge = List.concat (List.map
    (function
      |	Strich (f,ps) ->
        let ps' = List.map konvertiere_polygon'
          (List.filter (function p,r -> p<>[]) ps)  in
        if ps'=[]  then []  else [Strich' (f,ps')]
      |	Dicker_Strich (f,d,ps) -> 
        let ps' = List.map konvertiere_polygon'
          (List.filter (function p,r -> p<>[]) ps)  in
        if ps'=[]  then []  else [Dicker_Strich' (f,d,ps')]
      |	Flaechen (fs,ps) -> [Flaechen'
        (fs, List.map (function p,f1,f2 -> konvertiere_polygon' p,f1,f2)
          (List.filter (function (p,r),f1,f2 -> p<>[]) ps))])
    vektordinge)

  let map_vektordinge f_ = List.map
    (function
      | Strich (f,ps) -> Strich (f, List.map (map_polygon' f_) ps)
      | Dicker_Strich (f,d,ps) ->
        Dicker_Strich (f, d, List.map (map_polygon' f_) ps)
      |	Flaechen (fs,ps) -> Flaechen
        (fs, List.map (function p,f1,f2 -> map_polygon' f_ p,f1,f2) ps))

  let verschiebe_dinge dx dy = map_vektordinge (verschiebe_linie dx dy)
  let drehe_dinge winkel = map_vektordinge (drehe_linie (winkel*.pi/.180.0))
  let skaliere_dinge faktor = map_vektordinge (skaliere_linie faktor)
  let spiegel_dinge = map_vektordinge spiegel_linie

end



type rahmen =
  | Linie of linie
  | Teilung of
    (float * float * float * float * punkt * punkt * rahmen * rahmen)
      (* xmin, ymin, xmax, ymax, p1, p2, Linie p1-p3, Linie p3-p2 *)

let rahmen_rand r = match r  with
  | Linie (Strecke (p1,p2)) ->
    let (x1,y1),(x2,y2) = p1,p2  in
    min x1 x2, min y1 y2, max x1 x2, max y1 y2, p1, p2
  | Linie (Kreis ((x,y),r)) ->
    x-.r, y-.r, x+.r, y+.r, (0.0,0.0), (0.0,0.0)
  | Linie (Bogen (p,r,g,w1,w2)) ->
    let p1,p2 = kreispunkt p r w1, kreispunkt p r w2  in
    let (x,y),(x1,y1),(x2,y2) = p,p1,p2  in
    let xe = x1::x2::(List.concat (List.map
      (function x,w -> if winkel_interval w1 w2 w g = Innen  then [x]  else [])
      [x+.r, 0.0;  x-.r, pi]))  in
    let ys = y1::y2::(List.concat (List.map
      (function y,w -> if winkel_interval w1 w2 w g = Innen  then [y]  else [])
      [y+.r, pi*.0.5;  y-.r, pi*.1.5]))  in
    list_min (function x -> x) xe, list_min (function y -> y) ys,
    list_max (function x -> x) xe, list_max (function y -> y) ys,
    p1, p2
  | Linie (Spline (p1,p1',p2',p2)) ->
    let (x1,y1),(x1',y1'),(x2',y2'),(x2,y2) = p1,p1',p2',p2  in
    let x_extremstellen =
      let a = x2-.3.0*.(x2'-.x1')-.x1  in
      let b = x2'-.2.0*.x1'+.x1  in
      let c = x1'-.x1  in
      List.map
        (function t -> x1+.t*.(3.0*.c+.t*.(3.0*.b+.t*.a)))
        (0.0::1.0::(List.filter
          (function t -> 0.0<t && t<1.0)
          (Polynome.loese_2 a (2.0*.b) c)))  in
    let y_extremstellen =
      let a = y2-.3.0*.(y2'-.y1')-.y1  in
      let b = y2'-.2.0*.y1'+.y1  in
      let c = y1'-.y1  in
      List.map
        (function t -> y1+.t*.(3.0*.c+.t*.(3.0*.b+.t*.a)))
        (0.0::1.0::(List.filter
          (function t -> 0.0<t && t<1.0)
          (Polynome.loese_2 a (2.0*.b) c)))  in
    list_min (function x -> x) x_extremstellen,
    list_min (function y -> y) y_extremstellen,
    list_max (function x -> x) x_extremstellen,
    list_max (function y -> y) y_extremstellen,
    p1, p2
  | Teilung (x1,y1,x2,y2,p1,p2,r13,r32) -> x1,y1,x2,y2,p1,p2

let kombiniere_rahmen r1 r2 =
  let x1,y1,x2,y2,p1,p3 = rahmen_rand r1  in
  let x1',y1',x2',y2',p3,p2 = rahmen_rand r2  in
  Teilung (min x1 x1', min y1 y1', max x2 x2', max y2 y2', p1, p2, r1, r2)

let unterteile nahe f t1 t2 =
  (* Ersetzt die Kurve f zwischen t1 und t2 durch einen Rahmen, in dem
     ein Streckenzug steckt.
     nahe gibt an, wann nicht weiter unterteilt werden muß. *)
  let rec intern t ft t' ft' =
    if nahe ft ft'
      then Linie (Strecke (ft,ft'))
      else
        let t'' = (t+.t')/.2.0  in
        let ft'' = f t'' in
        kombiniere_rahmen (intern t ft t'' ft'') (intern t'' ft'' t' ft')  in
  intern t1 (f t1) t2 (f t2)


let unterteile_kontinuierlich maxabstand = unterteile
  (function p1 -> function p2 -> abstand p1 p2 <= maxabstand)

let unterteile_raster pixelkantenlaenge f =
  let runde x = ((floor (x/.pixelkantenlaenge))+.0.5)*.pixelkantenlaenge  in
  unterteile
    (function p1 -> function p2 -> abstand p1 p2 < 1.5*.pixelkantenlaenge)
    (function t -> let x,y = f t  in runde x, runde y)



module type Unterteile_Methode = sig

  val unterteile: float -> polygon -> rahmen list * rahmen list
    (* erstes Ergebnis: Für Abstand   zweites: für Windung *)

end

module Unterteile_kontinuierlich = struct

  let unterteile pixelkantenlaenge pol =
    List.map
      (function
      | Strecke s -> Linie (Strecke s)
      | Kreis k -> Linie (Kreis k)
      | Bogen b -> Linie (Bogen b)
      | Spline (p1,p1',p2',p2) -> unterteile_kontinuierlich
          pixelkantenlaenge
          (spline p1 p1' p2' p2)
          0.0  1.0)
      pol,
    List.map (function l -> Linie l) pol

end

module Unterteile_Raster = struct

  let unterteile_linie_raster pixelkantenlaenge linie =
    let unterteile = unterteile_raster pixelkantenlaenge  in
    match linie  with
    | Strecke (p1,p2) -> unterteile (function t -> addiere_punkte
        (skaliere_punkt (1.0-.t) p1) (skaliere_punkt t p2)) 0.0 1.0
    | Kreis (p,r) -> kombiniere_rahmen
      (unterteile (kreispunkt p r) 0.0 pi)
      (unterteile (kreispunkt p r) pi (pi+.pi))
    | Bogen (p,r,g,w1,w2) ->
      let w1,w2 = bereinige_winkel w1, bereinige_winkel w2  in
      let w1,w2 = if g
        then if w1<=w2  then w1,w2  else w1, w2+.pi+.pi
        else if w1>=w2  then w1,w2  else w1+.pi+.pi, w2  in
      unterteile (kreispunkt p r) w1 w2
    | Spline (p1,p1',p2',p2) -> unterteile (spline p1 p1' p2' p2) 0.0 1.0

  let unterteile pixelkantenlaenge pol =
    let unterteilt = List.map
      (unterteile_linie_raster pixelkantenlaenge)
      pol  in
    unterteilt, unterteilt

end



module type Zeichne_Methode = sig

  val mische: farbe lazyval ref -> farbe -> float -> farbe
    (* float: Anteil der ersten Farbe *)

end

module Zeichne_kontinuierlich = struct

  let mische farbe1 farbe2 anteil = if anteil>=1.0
    then get_lazy farbe1
    else if anteil<=0.0
      then farbe2
      else misch2 farbe2 (get_lazy farbe1) anteil

end

module Zeichne_diskret = struct

  let mische farbe1 farbe2 anteil = if anteil>0.5
    then get_lazy farbe1
    else farbe2

end



let rec abstand_rahmen r p0 maxabstand = match r  with
  | Linie l -> abstand_linie l p0
  | Teilung (x1,y1,x2,y2,p1,p2,r1,r2) ->
    let x,y = p0  in
    if (x<x1-.maxabstand) || (x>x2+.maxabstand) ||
        (y<y1-.maxabstand) || (y>y2+.maxabstand)
      then maxabstand
      else min
        (abstand_rahmen r1 p0 maxabstand)
        (abstand_rahmen r2 p0 maxabstand)

let abstand p0 maxabstand = list_min
  (function r -> abstand_rahmen r p0 maxabstand)

let rec windung_rahmen r p0 = match r  with
  | Linie l -> windung_linie l p0
  | Teilung (x1,y1,x2,y2,p1,p2,r1,r2) ->
    let x,y = p0  in
    if x<x1 || x>x2 || y<y1 || y>y2
      then windung_strecke p0 p1 p2
      else (windung_rahmen r1 p0)+.(windung_rahmen r2 p0)

let windungszahl p0 = list_sum (function r -> windung_rahmen r p0)

module Male = functor (U: Unterteile_Methode) ->
    functor (Z: Zeichne_Methode) -> struct

  include Methode_Daten_abstrakt

  type vektording'' =
    | Strich'' of (farbe * int list)
    | Dicker_Strich'' of (farbe * float * int list)
    | Flaechen'' of
      (farbe * (int * bool) list * (int * bool * farbe) list) list

  type vektorbild'' =
    int * (rahmen list * rahmen list) array * vektording'' list

  let konvertiere pixelkantenlaenge bild =
    let extrahiere_polygon pol =
      let rec suche i = function
      |	[] -> None
      |	h::t -> if h=pol  then Some i  else suche (i+1) t  in
      suche 0  in
    let extrahiere_polygone pd = List.fold_left
      (function (n,pols),exts -> function pol,r ->
        match extrahiere_polygon pol pols  with
        | None -> (n+1,pols@[pol]),(n,r)::exts
        | Some i -> (n,pols),(i,r)::exts)
      (pd,[])  in
    let ohne_richtung = List.map fst  in
    let (n,pols),bild' = List.fold_left
      (function pd,dinge -> (function
        | Strich' (f,ps) ->
          let pd',ps' = extrahiere_polygone pd ps  in
          pd',dinge@[Strich'' (f,ohne_richtung ps')]
        | Dicker_Strich' (f,d,ps) ->
          let pd',ps' = extrahiere_polygone pd ps  in
          pd',dinge@[Dicker_Strich'' (f,d,ohne_richtung ps')]
        | Flaechen' (fs,ps) ->
          let pd',ps' = extrahiere_polygone pd
            (List.map (function p,s,s' -> p) ps)  in
          let ps'' = List.map
            (function (p,r),s,s' ->
              let Some p' = extrahiere_polygon p (snd pd')  in
              (p',r),s,s')
            ps  in
          pd',dinge@[Flaechen'' (Array.to_list (Array.mapi
	    (function i -> function f ->
	      let vollhauptkanten = List.map
                (function (p,r),s,Some s' -> p,r,fs.(s'))
                (List.filter (function p,s,s' -> s=i && s'<>None) ps'')  in
	      let halbhauptkanten = List.map
                (function (p,r),s,s' -> p,r)
                (List.filter (function p,s,s' -> s=i && s'=None) ps'')  in
	      let nebenkanten = List.map
                (function (p,r),s,s' -> p,not r,fs.(s))
                (List.filter (function p,s,s' -> s'=Some i) ps'')  in
              let vollkanten = vollhauptkanten@nebenkanten  in
	      f,
              halbhauptkanten @ (List.map (function p,r,s -> p,r) vollkanten),
              vollkanten)
            fs))]))
      ((0,[]),[])
      bild  in
    n,
    Array.init n
      (function i -> U.unterteile pixelkantenlaenge (List.nth pols i)),
    bild'

  let male bild aufloesung (breite,hoehe,farben) =
    let halbaufloseung = aufloesung*.0.5  in
    let npols,pols,bild = konvertiere aufloesung bild  in
    (breite,hoehe,
      function p ->
        let abstaende = Array.make npols (0.0, 0.0)  in
        let abstand maxabstand i =
          let abstandi,maxabstandi = abstaende.(i)  in
          if maxabstandi>=maxabstand
            then abstandi
            else
              let d = abstand p maxabstand (fst pols.(i))  in
              (abstaende.(i) <- (d,maxabstand); d)  in
        let abstand' maxabstand = list_min (abstand maxabstand)  in
        let windungen = Array.make npols None  in
        let windung i = match windungen.(i)  with
	| None ->
          let w = windungszahl p (snd pols.(i))  in
          (windungen.(i) <- Some w; w)
	| Some w -> w  in
        let windung_drin pols = windung_drin (list_sum
          (function pol,r -> let w=windung pol  in  if r  then -.w  else w)
          pols)  in
        get_lazy (List.fold_left
          (function f -> (function
	    | Strich'' (farbe,pols) -> set_lazy (function u ->
              Z.mische f farbe ((abstand' aufloesung pols)/.aufloesung))
	    | Dicker_Strich'' (farbe,dicke,pols) -> set_lazy (function u ->
              Z.mische f farbe
                (((abstand' (dicke+.halbaufloseung) pols)
                  -.dicke)/.aufloesung+.0.5))
	    | Flaechen'' flaechen -> set_lazy (function u ->
              try
                let farbe,kanten,vollkanten = List.find
                  (function farbe,kanten,vollkanten ->
                    try windung_drin kanten  with | Drauf -> true)
                  flaechen  in
                let abstaende =
		  List.filter (function d,f' -> d<0.5)
                  (List.map (function pol,r,f' ->
                    (abstand aufloesung pol)/.aufloesung,f')
                  vollkanten)  in
                if abstaende = []
                  then farbe
                  else misch
                    ((0.5+.(list_min fst abstaende), farbe)::
                      (List.map (function d,f -> 0.5-.d,f) abstaende))
              with
              |	Not_found -> get_lazy f)))
          (set_lazy (function u -> farben p))
          bild))

end

module Male_mit_aa = Male(Unterteile_kontinuierlich)(Zeichne_kontinuierlich)
module Male_ohne_aa = Male(Unterteile_Raster)(Zeichne_diskret)


