(*
   Copyright 2006,2010 by Mark Weyer
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
*)

open Farbe

type punkt = float * float

type bildchen = int * int * (punkt -> farbe)
  (* Die ints sind Breite und Höhe in Elementarquadraten *)

val monochrom: farbe -> int -> int -> bildchen
val spiegel_x: bildchen -> bildchen
val kombiniere_bildchen: int -> int -> (int * int * bildchen) list -> bildchen
  (* Breite, Höhe, zu kombinierende Bildchen mit Positionen *)
val ueberlagerung: bildchen -> bildchen -> bildchen option -> bildchen
  (* ueberlagerung unten oben maske
     malt oben über unten.
     Dabei wird die Transparenz von oben aus dem durchsichtig-Kanal von
     maske genommen. Ist maske None, so stattdessen aus dem von oben.
     Breite und Höhe des Ergebnisses sind die von unten. *)



type pixelbild = int * int * farbe array array
  (* Die kleinen array sind Zeilen.
     Ein pixelbild hat den Ursprung links oben, ein bildchen links unten! *)

val berechne: int -> bildchen -> pixelbild
val abstrahiere : int -> pixelbild -> bildchen
  (* Der int ist die Anzahl an Pixeln pro Elementarquadrat. *)

val ausschnitt : int -> int -> int -> int -> pixelbild -> pixelbild
  (* Die ints sind x0,y0,x1,y1. Der Ausschnitt ist von (x0,y0) einschließlich
     bis (x1,y1) ausschließlich. *)
val kleb : bool -> pixelbild -> pixelbild -> pixelbild
  (* Hängt die Bilder aneinander. Der bool gibt an, ob das waagerecht
     geschehen soll (sonst senkrecht). Je nachdem muß die Höhe oder Breite
     der Bilder übereinstimmen. *)
val durchschnitt : int -> pixelbild -> pixelbild
  (* Es werden je n*n pixel zusammengefasst, wobei n der int ist.
     Es wird erwartet, daß die Maße des Bildes durch n teilbar sind. *)

val extrahiere_farben: pixelbild -> palette * farbkarte
val extrahiere_verteilung : pixelbild -> farbverteilung

type farbreduktions_methode =
| Heuristik_mittlerer_euklidischer
| Heuristik_maximaler_euklidischer

val reduziere_farben :
  farbreduktions_methode -> palette -> int -> pixelbild -> palette
  (* Die palette und der int sind wie bei Farbe.reduziere_farben1. *)



val anz_xpm_zeichen : int

val gib_xpm_aus_exakt: rgb_farbe -> string -> pixelbild -> unit
val gib_xpm_aus_palette: rgb_farbe -> palette -> string -> pixelbild -> unit
val gib_xpm_aus_anzahl: ?methode:farbreduktions_methode ->
  rgb_farbe -> int -> string -> pixelbild -> unit
val gib_xpm_aus: ?methode:farbreduktions_methode ->
  rgb_farbe -> string -> pixelbild -> unit
  (* Die rgb_farbe wird bei Mischfarben für durchsichtig und hintergrund
     benutzt.
     Der string ist der Dateiname.
     Die letzten beiden Versionen reduzieren auf eine Anzahl an Farben.
     Bei der letzten ist diese Anzahl anz_xpm_zeichen.
     Die Default-Methode ist dabei Heuristik_maximaler_euklidischer. *)

val gib_ppm_aus: string -> pixelbild -> unit
  (* Der nicht-RGB-Anteil der Pixel wird ignoriert. *)

val lies_xpm: string -> pixelbild
val lies_ppm: string -> pixelbild
val lies_pam: string -> pixelbild (* nur RGB_ALPHA *)

