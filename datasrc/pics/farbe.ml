(*
   Copyright 2006,2008,2010,2011 by Mark Weyer

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

open Natmod
open Vektor

module Kanaele = Fuenf
module Farbe = Vektor(Kanaele)
module Rgb = Vektor(Drei)

let durchsichtig_kanal = 3
let hintergrund_kanal = 4

let anzahl_spezialfarben = 2
let anzahl_farben = 3+anzahl_spezialfarben

let test = if Kanaele.n != anzahl_farben  then raise Falsche_Dimension

type rgb_farbe = Rgb.t
type rgba_farbe = Vektor(Vier).t

type farbe = Farbe.t
  (* rot, grün, blau, durchsichtig, Hintergrund *)

module Von_rgb = Laenger(Drei)(Kanaele)
module Von_rgba = Laenger(Vier)(Kanaele)
module Zu_rgb = Kuerzer(Kanaele)(Drei)

let compare = Farbe.compare

let rgbrgb r g b = Rgb.aus_array [| r; g; b |]
let rgb_grau g = rgbrgb g g g
let von_rgb = Von_rgb.laenger
let von_rgba rgba =
  let f = Von_rgba.laenger rgba  in
  Farbe.setz_koord f durchsichtig_kanal
    (1.0-.(Farbe.koord f durchsichtig_kanal))

let reinkanal i = Farbe.aus_funktion (fun j -> if i=j  then 1.0  else 0.0)

let durchsichtig = reinkanal durchsichtig_kanal
let hintergrund = reinkanal hintergrund_kanal

let grau x = Farbe.aus_funktion (function i -> if i<3  then x  else 0.0)

let rot = von_rgb (rgbrgb 1.0 0.0 0.0)
let gruen = von_rgb (rgbrgb 0.0 1.0 0.0)
let blau = von_rgb (rgbrgb 0.0 0.0 1.0)
let schwarz = grau 0.0
let weiss = grau 1.0

let zufallsfarbe helligkeit kontrast =
  let ton = Random.float 3.0  in
  let r,g,b = if ton<=1.0
  then (1.0-.ton, ton, 0.0)
  else if ton<=2.0
    then (0.0, 2.0-.ton, ton-.1.0)
    else (ton-.2.0, 0.0, 3.0-.ton)  in
  let max = max (max r g) b  in
  let c1 = kontrast /. max  in
  let c2 = helligkeit -. kontrast  in
  let skalier x = c1 *. x +. c2  in
  rgbrgb (skalier r) (skalier g) (skalier b)

let zu_rgb d h f =
  Rgb.plus (Zu_rgb.kuerzer f) (Rgb.plus
    (Rgb.mal (Farbe.koord f durchsichtig_kanal) d)
    (Rgb.mal (Farbe.koord f hintergrund_kanal) h))

let nur_rot f = Farbe.koord f 0
let nur_gruen f = Farbe.koord f 1
let nur_blau f = Farbe.koord f 2
let nur_durchsichtig f = Farbe.koord f durchsichtig_kanal



let misch2 alt neu mischung =
  Farbe.plus
    (Farbe.mal (1.0-.mischung) alt)
    (Farbe.mal mischung neu)

let misch farben =
  let w,f = List.fold_left
    (function w,f -> function w',f' ->
      w+.w', Farbe.plus f (Farbe.mal w' f'))
    (0.0,schwarz)
    farben  in
  Farbe.mal (1.0/.w) f

let mischspezial f f' =
  let weiss = Farbe.koord f' 2  in
  let bunt = (Farbe.koord f' 0)-.weiss  in
  Farbe.aus_funktion (fun i -> max
    (bunt*.(Farbe.koord f i) +. weiss)
    (if i<3  then 0.0  else Farbe.koord f' i))



module FarbMap = Map.Make(Farbe)

type palette = farbe array
type farbkarte = int FarbMap.t
type farbverteilung = (farbe*int) array


let summe plus f n =
    (* Berechnet \sum\limits_{0<=i<n}(f i) numerisch stabil *)
  let rec subsumme i1 i2 = if i1=i2
    then f i1
    else
      let i12 = (i1+i2)/2  in
      plus (subsumme i1 i12) (subsumme (i12+1) i2)  in
  subsumme 0 (n-1)


module Mat = Matrix(Kanaele)(Kanaele)
module Quad = QuadMatrix(Kanaele)

let wichtsumme verteilung teil plus mal f = summe
  plus
  (fun i ->
    let farbe,n = verteilung.(teil.(i))  in
    mal (float_of_int n) (f farbe))
  (Array.length teil)

let teilmap f verteilung teil = Array.map
  (fun i ->
    let farbe,n = verteilung.(i)  in
    f i farbe n)
  teil


let anzahl verteilung = Array.fold_left
  (fun a -> fun (f,n) -> a+n)
  0  verteilung

let zentriere verteilung anzahl teil =
  let summe = wichtsumme verteilung teil Farbe.plus Farbe.mal (fun f -> f)  in
  let mittel = Farbe.mal (-1.0/.(float_of_int anzahl)) summe  in
  teilmap (fun i -> fun f -> fun n -> Farbe.plus f mittel) verteilung teil

let richtung verteilung teil zentriert =
  Quad.eigenvektor1 (wichtsumme verteilung teil Mat.plus Mat.mal_skalar
    (fun farbe -> Mat.aus_funktion
      (fun i -> fun j -> (Farbe.koord farbe i)*.(Farbe.koord farbe j))))

let projektion verteilung teil richtung = teilmap
  (fun i -> fun f -> fun n -> i,Farbe.produkt f richtung)
  verteilung teil

let spalte verteilung anzahl projektion =
  let ziel = anzahl/2  in
  let rec mitte i n =
    let i',x = projektion.(i)  in
    let f,dn = verteilung.(i')  in
    let n' = n+dn  in
    if n'>=ziel
      then if ziel-n >= n'-ziel
        then i+1,n',anzahl-n'
        else i,n,anzahl-n
      else mitte (i+1) n'  in
  let imitte,n1,n2 = mitte 0 0  in
  n1,
  Array.init imitte (fun i ->
    let i',x = projektion.(i)  in
    i'),
  n2,
  Array.init ((Array.length projektion)-imitte) (fun i ->
    let i',x = projektion.(i+imitte)  in
    i')

let reduziere_farben1 palette verteilung zielanzahl =
  let rec halbiere zielanzahl anzahl teil = if Array.length teil <= zielanzahl
    then teilmap
      (fun i -> fun farbe -> fun n -> farbe)
      verteilung teil
    else if zielanzahl=1
      then
        let summe =
	  wichtsumme verteilung teil Farbe.plus Farbe.mal (fun f -> f)  in
        [| Farbe.mal (1.0/.(float_of_int anzahl)) summe |]
      else
        let zentriert = zentriere verteilung anzahl teil  in
        let richtung = richtung verteilung teil zentriert  in
        let projiziert = projektion verteilung teil richtung  in
	Array.stable_sort
	  (fun (i1,x1) -> fun (i2,x2) -> Pervasives.compare x1 x2)
	  projiziert;
        let anz1,teil1,anz2,teil2 = spalte verteilung anzahl projiziert  in
	(* Berechnung in float, weil es 32Bit-ints schon mal sprengen könnte *)
	let anz1f,anzahlf,zielanzahlf =
	  float_of_int anz1,
	  float_of_int anzahl,
	  float_of_int zielanzahl  in
	let ziel1 = truncate (zielanzahlf*.anz1f/.anzahlf+.0.5)  in
	let ziel1,ziel2 = if ziel1=0
	  then 1,zielanzahl-1
	  else if ziel1=zielanzahl
	    then zielanzahl-1,1
	    else ziel1,zielanzahl-ziel1  in
	let len1,len2 = Array.length teil1, Array.length teil2  in
	let ziel1,ziel2 = if ziel1>len1
	  then len1, zielanzahl-len1
  	  else if ziel2>len2
	    then zielanzahl-len2, len2
	    else ziel1,ziel2  in
	Array.append
          (halbiere ziel1 anz1 teil1)
          (halbiere ziel2 anz2 teil2)  in
  let ziel = zielanzahl-Array.length palette  in
  if ziel <0
  then palette
  else
    let teil = Array.init (Array.length verteilung) (fun i -> i)  in
    Array.append palette (halbiere ziel (anzahl verteilung) teil)



(* Einige Dinge für Farbquader - dargestellt durch Kanalweise minimale und
   maximale Farbe im Quader. *)

let min2 f1 f2 = Farbe.aus_funktion
    (* Kanalweises Minimum zweier Farben *)
  (fun j -> min (Farbe.koord f1 j) (Farbe.koord f2 j))

let max2 f1 f2 = Farbe.aus_funktion
    (* Kanalweises Maximum zweier Farben *)
  (fun j -> max (Farbe.koord f1 j) (Farbe.koord f2 j))

let minquaderabstand2 f min max =
    (* Der kleinstmögliche Abstand von f zu einer Farbe im Quader.
       (Abstand heißt, wie hier überall, euklidischer Abstand im Quadrat.) *)
  let rec summe bisher j = if j<0
    then bisher
    else
      let xf,xm,xM = Farbe.koord f j, Farbe.koord min j, Farbe.koord max j  in
      let dx = if xf<xm  then xm-.xf  else if xf>xM  then xf-.xM  else 0.0  in
      summe (bisher+.dx*.dx) (j-1)  in
  summe 0.0 (Kanaele.n-1)

let maxquaderabstand2 f min max =
    (* Der größtmögliche Abstand von f zu einer Farbe im Quader.
       (Abstand heißt, wie hier überall, euklidischer Abstand im Quadrat.) *)
  let rec summe bisher j = if j<0
    then bisher
    else
      let xf,xm,xM = Farbe.koord f j, Farbe.koord min j, Farbe.koord max j  in
      let dx = if xf+.xf < xm+.xM  then xM-.xf  else xf-.xm  in
      summe (bisher+.dx*.dx) (j-1)  in
  summe 0.0 (Kanaele.n-1)

let durchmesser2 min max =
  let rec summe bisher j = if j<0
    then bisher
    else
      let dx = (Farbe.koord max j) -. (Farbe.koord min j)  in
      summe (bisher +. dx*.dx) (j-1)  in
  summe 0.0 (Kanaele.n-1)

let maxabstand2_quader (min,max) (min',max') =
  durchmesser2 (min2 min min') (max2 max max')


let minimum kleiner f n =
    (* Gibt (i,f i) für das i aus, das (f i) in {0,...,n-1} minimiert. *)
  let rec suche i im ym = if i=0
    then im,ym
    else
      let y = f i  in
      if kleiner y ym
        then suche (i-1) i y
        else suche (i-1) im ym  in
  suche (n-1) 0 (f 0)


type 'a farb_baum =
  (* Binärer Suchbaum für Farben.
     Gespeichert werden nur Indices in eine Palette, nicht die Farben selbst.
     'a ist Zusatzinformation.
     Zusatzinformationen sind später:
     - unit oder
     - int ref.
       Damit wird gezählt, wieviele bereits gewählte Farben der Baum enthält.
   *)
  | Blatt of int * 'a
  | Knoten of int * float * farbe * farbe * 'a farb_baum * 'a farb_baum * 'a
    (* Spaltdimension, Schwellenwert, min, max, Kinder, Zusatzinfo.
       Das erste Kind bekommt alle Farben, deren Koordinate in der
       Spaltdimension kleiner als die Schwelle ist.
       min und max sind so, daß sie den gleichen Quader aufspannen,
       wie alle enthaltenen Farben. *)

type farbindex = unit farb_baum


let quader palette baum = match baum  with
| Blatt (i,a) -> let f = palette.(i)  in f,f
| Knoten (dim, schwelle, min, max, lbaum, rbaum, a) -> min,max

let spalt min max =
    (* Berechnet aus den Quaderdaten die Spaltdimension und -schwelle. *)
  let dim = fst (minimum (>)
    (fun j -> (Farbe.koord max j)-.(Farbe.koord min j))
    Kanaele.n)  in
  let schwelle = ((Farbe.koord min dim)+.(Farbe.koord max dim))*.0.5  in
  dim,schwelle
  

let rec verteile palette (teil : int array) (a : unit -> 'a) =
    (* Erzeugt einen 'a farb_baum, der genau die durch teil
       indizierten Farben enthält.
       Mehrfach vorkommende Farben sind im Baum nur einfach vertreten. *)
  let n = Array.length teil  in
  if n=1
    then Blatt (teil.(0), a ())
    else
      let minx j = snd (minimum (<)
	(fun i -> Farbe.koord palette.(teil.(i)) j)
	n)  in
      let maxx j = snd (minimum (>)
	(fun i -> Farbe.koord palette.(teil.(i)) j)
	n)  in
      let min = Farbe.aus_funktion minx  in
      let max = Farbe.aus_funktion maxx  in
      let dim,schwelle = spalt min max  in
      let links = Array.fold_left
          (* Anzahl der Farben im linken Teilbaum *)
        (fun n -> fun i -> if Farbe.koord palette.(i) dim < schwelle
	  then n+1
	  else n)
        0  teil  in
      if links=0  (* Dann sind alle Farben schon gleich *)
      then Blatt (teil.(0), a ())
      else
        let lteil = Array.make links 0  in
        let rteil = Array.make (n-links) 0  in
          (* Die Argumente für den rekursiven Aufruf; jetzt müssen sie erst
	     noch richtig initialisiert werden. *)
        ignore (Array.fold_left
          (fun (il,ir) -> fun i -> if Farbe.koord palette.(i) dim < schwelle
            then (
              lteil.(il)<-i;
              il+1, ir)
            else (
              rteil.(ir)<-i;
              il, ir+1))
          (0,0)  teil);
        Knoten (dim, schwelle, min, max,
          verteile palette lteil a,
          verteile palette rteil a,
          a ())

let mach_baum palette =
  verteile palette (Array.mapi (fun i -> fun f -> i) palette)

let mach_index palette = mach_baum palette (fun () -> ())


let rec fueg_ein palette baum farbe i = match baum  with
    (* Nimmt eine neue Farbe in einen unit farb_baum auf. *)
| Blatt (i',()) -> if i=i'
  then Blatt (i',())
  else
    let farbe' = palette.(i')  in
    let min = min2 farbe farbe'  in
    let max = max2 farbe farbe'  in
    let dim,schwelle = spalt min max  in
    if Farbe.koord farbe dim < Farbe.koord farbe' dim
      then Knoten (dim, schwelle, min, max, Blatt (i,()), Blatt (i',()), ())
      else Knoten (dim, schwelle, min, max, Blatt (i',()), Blatt (i,()), ())
| Knoten (dim, schwelle, min, max, lteil, rteil, ()) ->
  let min' = min2 min farbe  in
  let max' = max2 max farbe  in
  if Farbe.koord farbe dim < schwelle
    then Knoten (dim, schwelle, min', max',
      fueg_ein palette lteil farbe i,
      rteil,
      ())
    else Knoten (dim, schwelle, min', max',
      lteil,
      fueg_ein palette rteil farbe i,
      ())

let plaette palette baum n =
    (* Macht aus baum eine neue Palette (eine Teilmenge von palette).
       n ist die Anzahl der Farben in baum. *)
  let raus = Array.make n schwarz  in
    (* Wird gleich noch richtig initialisiert. *)
  let rec schreite ir teil = match teil  with
    (* Geht durch den Baum durch; ir ist der nächst Index in raus. *)
  | Blatt (i,a) -> (raus.(ir) <- palette.(i); ir+1)
  | Knoten (dim, schwelle, min, max, lteil, rteil, a) ->
    schreite (schreite ir lteil) rteil  in
  ignore (schreite 0 baum);
  raus


let rec maxabstand palette f ib db baum = match baum  with
    (* Im Baum wird die Farbe gesucht, die von f am weitesten entfernt ist.
       Von ihr wird Nummer und Abstand zu f ausgegeben.
       Dabei ist (ib,db) ein bereits bekannter Kandidat. *)
| Blatt (i,a) ->
  let d = Farbe.abstand2 f palette.(i)  in
  if d>db
    then i,d
    else ib,db
| Knoten (dim,schwelle,min,max,lbaum,rbaum,a) ->
  if maxquaderabstand2 f min max < db
    then ib,db
    else if Farbe.koord f dim < schwelle
        (* Wir suchen zuerst in der entfernteren Hälfte. *)
      then
        let ib',db' = maxabstand palette f ib db rbaum  in
        maxabstand palette f ib' db' lbaum
      else
        let ib',db' = maxabstand palette f ib db lbaum  in
        maxabstand palette f ib' db' rbaum


let rec maxabstand_paar palette baum1 baum2 i1b i2b db = match baum1  with
    (* In den Bäumen werden die Farben gesucht, die voneinander am weitesten
       entfernt sind. Es soll je Baum eine Farbe sein.
       Von ihnen werden Nummern und Abstand ausgegeben.
       Dabei ist (i1b,i2b,db) ein bereits bekannter Kandidat. *)
  | Blatt (i1,a) ->
    let i2,d = maxabstand palette palette.(i1) (-1) db baum2  in
    if d>db
      then i1,i2,d
      else i1b,i2b,db
  | Knoten (dim,schwelle,min,max,lbaum,rbaum,a) ->
    let q2 = quader palette baum2  in
    if maxabstand2_quader (min,max) q2 <= db
      then i1b,i2b,db
      else
        let ql,qr = quader palette lbaum, quader palette rbaum  in
        let dl,dr = maxabstand2_quader ql q2, maxabstand2_quader qr q2  in
        if dl>dr
          then
            let i1b',i2b',db' =
              maxabstand_paar palette baum2 lbaum i1b i2b db  in
	        (* Bei all diesen Aufrufen ist es wichtig, daß baum1 und baum2
		   vertauscht werden, da die Fallunterscheidung oben nur für
		   baum1 gemacht wird. *)
            maxabstand_paar palette baum2 rbaum i1b' i2b' db'
          else
            let i1b',i2b',db' =
              maxabstand_paar palette baum2 rbaum i1b i2b db  in
            maxabstand_paar palette baum2 lbaum i1b' i2b' db'

let rec maxabstand_paar' palette baum i1b i2b db = match baum  with
    (* Wie maxabstand_paar, nur daß baum1=baum2. *)
  | Blatt (i,a) -> i1b,i2b,db
  | Knoten (dim,schwelle,min,max,lbaum,rbaum,a) ->
    if durchmesser2 min max <= db
      then i1b,i2b,db
      else
        let i1b',i2b',db' = maxabstand_paar palette lbaum rbaum i1b i2b db  in
        let (lmin,lmax),(rmin,rmax) =
	  quader palette lbaum, quader palette rbaum  in
        let dl,dr = durchmesser2 lmin lmax, durchmesser2 rmin rmax  in
        if dl>dr
          then
            let i1b'',i2b'',db'' =
              maxabstand_paar' palette lbaum i1b' i2b' db'  in
              maxabstand_paar' palette rbaum i1b'' i2b'' db''
          else
            let i1b'',i2b'',db'' =
              maxabstand_paar' palette rbaum i1b' i2b' db'  in
              maxabstand_paar' palette lbaum i1b'' i2b'' db''

let max_abstand_paar palette baum =
  let i1,i2,d = maxabstand_paar' palette baum (-1) (-1) (-1.0)  in
  i1,i2


let rec zaehle farbe baum = match baum  with
    (* Geht von einem (int * bool) ref farb_baum aus und teilt ihm mit,
       daß eine neue Farbe aufgenommen wurde. Entsprechend wird die
       Zusatzinformation angepasst. *)
  | Blatt (i,drin) -> drin := !drin+1
  | Knoten (dim, schwelle, min, max, lteil, rteil, drin) ->
    (drin := !drin+1;
    if Farbe.koord farbe dim < schwelle
      then zaehle farbe lteil
      else zaehle farbe rteil)


let dmax = float_of_int (Kanaele.n + 1)
  (* Sollte größer als jedes Abstandsquadrat sein.
     Hier geht die Annahme ein, daß Werte von Farbkanälen
     zwischen 0 und 1 liegen. *)

let rec minabstand palette f ib db baum = match baum  with
    (* Im Baum wird die Farbe gesucht, die f am nächsten ist.
       Von ihr wird Nummer und Abstand zu f ausgegeben.
       Dabei ist (ib,db) ein bereits bekannter Kandidat. *)
| Blatt (i,a) ->
  let d = Farbe.abstand2 f palette.(i)  in
  if d<db
    then i,d
    else ib,db
| Knoten (dim,schwelle,min,max,lbaum,rbaum,a) ->
  if minquaderabstand2 f min max >= db
    then ib,db
    else if Farbe.koord f dim < schwelle
        (* Wir suchen zuerst in der näheren Hälfte. *)
      then
        let ib',db' = minabstand palette f ib db lbaum  in
        minabstand palette f ib' db' rbaum
      else
        let ib',db' = minabstand palette f ib db rbaum  in
        minabstand palette f ib' db' lbaum

let naechste_farbe palette baum farbe =
  fst (minabstand palette farbe (-1) dmax baum)


exception Zu_Klein

let rec minabstand' palette ds f db baum = match baum  with
  (* Der minimale Abstand interessiert uns nur, falls er mehr als ds ist. *)
| Blatt (i,()) ->
  let d = Farbe.abstand2 f palette.(i)  in
  if d<=ds
    then raise Zu_Klein
  else if d<db
    then d
    else db
| Knoten (dim,schwelle,min,max,lbaum,rbaum,()) ->
  if maxquaderabstand2 f min max <= ds
    then raise Zu_Klein
    else if minquaderabstand2 f min max >= db
      then db
      else
        if Farbe.koord f dim < schwelle
	  then
            let db' = minabstand' palette ds f db lbaum  in
            minabstand' palette ds f db' rbaum
          else
            let db' = minabstand' palette ds f db rbaum  in
            minabstand' palette ds f db' lbaum

let drin baum = match baum  with
| Blatt (i,drin) -> !drin
| Knoten (dim, schwelle, min, max, lteil, rteil, drin) -> !drin

let rec maxminabstand palette gross klein ib db = match gross  with
| Blatt (i,r) -> (try
    i, minabstand' palette db palette.(i) dmax klein
  with
    Zu_Klein -> ib,db)
| Knoten (dim, schwelle, min, max, lteil, rteil, dr) ->
  if if !dr>0  then durchmesser2 min max <= db  else false
    then ib,db
    else if drin lteil < drin rteil
      then
        let ib',db' = maxminabstand palette lteil klein ib db  in
        maxminabstand palette rteil klein ib' db'
      else
        let ib',db' = maxminabstand palette rteil klein ib db  in
        maxminabstand palette lteil klein ib' db'


let reduziere_farben2 festepalette palette zielanzahl =
  let feste_anz = Array.length festepalette  in
  if feste_anz >= zielanzahl
  then festepalette
  else
    let palette = Array.append festepalette palette  in
    if zielanzahl >= Array.length palette
      then palette
      else
        let gross = mach_baum palette (fun () -> ref 0)  in
        let anfang, n_anfang = if feste_anz = 0
          then (
            let i1,i2 = max_abstand_paar palette gross  in
            let farbe1 = palette.(i1)  in
            let farbe2 = palette.(i2)  in
            zaehle farbe1 gross;
            zaehle farbe2 gross;
            fueg_ein palette (Blatt (i1,())) farbe2 i2,  2)
          else (
            Array.iter (fun farbe -> zaehle farbe gross) festepalette;
            mach_baum festepalette (fun () -> ()),  feste_anz)  in
        let rec sammle klein n = if n>=zielanzahl
          then plaette palette klein n
          else
            (let i,d = maxminabstand palette gross klein (-1) (-1.0)  in
            let farbe = palette.(i)  in
            zaehle farbe gross;
            sammle (fueg_ein palette klein farbe i) (n+1))  in
        sammle anfang n_anfang


