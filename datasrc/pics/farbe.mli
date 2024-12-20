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

type farbe
type rgb_farbe = Vektor(Drei).t
type rgba_farbe = Vektor(Vier).t

val compare : farbe -> farbe -> int

val rgbrgb : float -> float -> float -> rgb_farbe
val rgb_grau : float -> rgb_farbe
val von_rgb: rgb_farbe -> farbe
val von_rgba: rgba_farbe -> farbe
val durchsichtig: farbe
val hintergrund: farbe

val rot : farbe
val gruen : farbe
val blau : farbe
val grau : float -> farbe
val schwarz : farbe
val weiss : farbe

val zufallsfarbe : float -> float -> rgb_farbe
  (* Die Argumente sind Helligkeit (größter Kanalwert)
     und Kontrast (Abstand zum kleinsten Kanalwert). *)

val nur_rot: farbe -> float
val nur_gruen: farbe -> float
val nur_blau: farbe -> float
val nur_durchsichtig: farbe -> float
  (* extrahiert den Kanal *)

val zu_rgb: rgb_farbe -> rgb_farbe -> farbe -> rgb_farbe
  (* Erste Argumente: Ersatz für durchsichtig und hintergrund  *)

val misch2: farbe -> farbe -> float -> farbe
  (* Der float ist das Gewicht der zweiten farbe. *)

val misch: (float * farbe) list -> farbe
  (* Die floats sind relative Gewichte.
     Voraussetzung: Kein Gewicht negativ, nicht alle Gewichte 0 *)

val mischspezial: farbe -> farbe -> farbe
  (* Der Blaukanal der zweiten Farbe wird durch weiß ersetzt, der 
     rot-minus-blau-Kanal durch die erste Farbe. *)



module FarbMap : Map.S with type key=farbe

type palette = farbe array
type farbkarte = int FarbMap.t            (* Eine Palette rückwärts *)
type farbverteilung = (farbe*int) array   (* Eine Multimenge *)
type farbindex

val mach_index : palette -> farbindex

val naechste_farbe : palette -> farbindex -> farbe -> int

val reduziere_farben1 : palette -> farbverteilung -> int -> palette
  (* Macht median cut immer in der Richtung, die die Varianz maximiert.
     Das Minimierungsziel ist also mittlerer euklidischer Abstand.
     Die Laufzeit bei n ist-Farben, m soll-Farben und k Kanälen ist dann
       O((k^2*n + k^3/log delta + n*(log n))*log m),
     wobei delta das Verhältnis zwischen den beiden größten beteiligten
     Eigenwertbeträgen ist.

     Die übergebene palette enthält Farben, die auf jeden Fall übernommen
     werden sollen. *)

val reduziere_farben2 : palette -> palette -> int -> palette
  (* Sammelt greedy die m entferntesten Farben.
     Das Minimierungsziel ist also maximaler euklidischer Abstand.
     Die Laufzeit bei n ist-Farben, m soll-Farben und k Kanälen ist dann
       O(n^2*k + n*m^2*k)

     Die erste palette enthält Farben, die auf jeden Fall übernommen
     werden sollen. *)

