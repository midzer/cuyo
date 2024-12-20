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

open Farbe
open Graphik

type linie =
  | Strecke of (punkt * punkt)
  | Kreis of (punkt * float)
  | Bogen of (punkt * float * bool * float * float)
    (* bool=true, wenn es gegen den Uhrzeiger geht.
       Die Winkel sind im Bogenmaß *)
  | Spline of (punkt * punkt * punkt * punkt)
    (* Der Spline geht vom ersten Punkt zum vierten.
       Die anderen sind Zwischenkontrollpunkte,
       wie das bei Splines halt so ist.
       In dieser Variante geht der Spline nicht durch die Zwischenpunkte,
       verläuft aber in der konvexen Hülle aller vier Punkte.
       Die Ableitung beim ersten/vierten Punkt ist zum/vom zweiten/dritten
       Punkt ausgerichtet.
       Diese Sorte Spline hat auch irgendeinen Namen, glaub ich. *)



type polygon = linie list
  (* Dieser Typ wird sowohl für geschlossene, als auch für nicht geschlossene
     Linienzüge verwendet. *)

val verschiebe_polygon: float -> float -> polygon -> polygon
val drehe_polygon: float -> polygon -> polygon
  (* Drehwinkel ist in Grad *)
val skaliere_polygon: float -> polygon -> polygon
val spiegel_polygon: polygon -> polygon
  (* Gespiegelt wird an der y-Achse. *)



module type Malmethode = sig

  type polygon'   (* interne Version *)

  val konvertiere_polygon : polygon -> polygon'

  val punkt_auf_polygon_relativ : polygon' -> float -> punkt * float option
    (* Das float-Argument ist Zahl zwischen 0 und 1; sie gibt bei
       Parametrisierung nach Bogenlänge, normiert auf die Gesamtlänge, einen
       Punkt des Polygons an. Der ist das Ergebnis. Wenn dort eine Ableitung
       ungleich 0 vorhanden ist, wird sie auch ausgegeben
       (als Winkel in Grad). *)

  val rueckwaerts: polygon' -> polygon'
    (* Für geschlossene Flächen ist es wichtig, daß alle Linien des Rands in
       der gleichen Richtung durchlaufen werden. (Die Reihenfolge wiederum ist
       nicht wichtig.) Linienzüge, die zwei Flächen voneinander abtrennen,
       treten daher typischerweise in einer Fläche vorwärts und in der anderen
       rückwärts auf. Diese Funktion dreht Linienzüge in diesem Sinn um. *)

  type vektording =
    | Strich of (farbe * polygon' list)
    | Dicker_Strich of (farbe * float * polygon' list)
        (* Der float ist der Stiftradius. *)
    | Flaechen of (farbe array * (polygon' * int * int option) list)
        (* Die ints verweisen auf die Flächen beidseitig der polygone'.
           Für den zweiten int (wenn vorhanden) wird die Richtung des
           Polygons umgekehrt. Je Fläche muß insgeamt ein geschlossener
           Polygonzug entstehen. *)

  val flaeche : farbe -> polygon' list -> vektording
  val pixel_zu_dingen : farbe option -> pixelbild -> vektording list
    (* Das zu den Vektordingen gehörende Vektorbild ist genauso pixelig
       wie das Originalbild. Jedes Pixel erhält die Größe 1x1.
       Die gegebene Farbe, fals nicht None, wird durch das vektording
       _nicht_ reproduziert, übermalt den Untergrund also nicht. *)

  (* Bis auf Konvertierung und Dekorationen sind die zweiten Komponenten von
     Vektordingen vom Typ linie list list. Warum nicht einfach linie list?
     Damit man optimieren kann. Das setzt Kooperation des Benutzers voraus.
     Im besten Fall taucht jede linie in genau einem polygon' auf (wird genau
     einmal konvertiert; das polygon' darf mehrfach verwendet werden) und
     dabei sind die polygone' so groß wie möglich. *)

  val map_vektordinge: (linie -> linie) -> vektording list -> vektording list
  val verschiebe_dinge: float -> float -> vektording list -> vektording list
  val drehe_dinge: float -> vektording list -> vektording list
    (* Drehwinkel ist in Grad *)
  val skaliere_dinge: float -> vektording list -> vektording list
  val spiegel_dinge: vektording list -> vektording list
    (* Gespiegelt wird an der y-Achse. *)

  type vektorbild

  val erzeuge_vektorbild : vektording list -> vektorbild
  val male: vektorbild -> float -> bildchen -> bildchen
    (* Der float ist die Pixelkantenlänge *)

end



module Male_mit_aa : Malmethode
  (* Diese Version behält den Linienverlauf (im Rahmen der
     Approximationsgüte) exakt bei, wobei Pixelfarben Mischungen
     aus den Farben umliegender Objekte werden (antialiasing). *)

module Male_ohne_aa : Malmethode
  (* Diese Version ersetzt alle Linien durch Züge von Kanten zwischen
     (gerade oder diagonal) benachbarten Pixeln. Das sieht mehr wie
     handgemacht aus und ergibt bessere Kontraste, dafür ruckeligere
     Kantenverläufe. Die normalfarbe-Anteile der Spezialfarben werden
     ignoriert, da kein antialiasing stattfindet. *)

