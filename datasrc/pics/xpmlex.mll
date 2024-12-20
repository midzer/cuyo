(*
   Copyright 2006 by Mark Weyer

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

{
open Farbe

module Rgb = Vektor.Vektor(Natmod.Drei)

let hexzifferwert c =
  let w = int_of_char c  in
  if (w>=int_of_char '0') && (w<=int_of_char '9')
    then w-(int_of_char '0')
    else if (w>=int_of_char 'A') && (w<=int_of_char 'F')
      then 10+w-(int_of_char 'A')
      else 10+w-(int_of_char 'a')

let hexwert s i =
  (float_of_int (16*(hexzifferwert s.[i])+(hexzifferwert s.[i+1])))/.255.0
}

let hexziffer = ['0'-'9''A'-'F''a'-'f']

rule xpm =
  parse ([' ''\t''\n']|("//"[^'\n']*'\n')|("/*"([^'*']|('*'[^'/']))*"*/"))+ {
    (* C/C++ whitespace *)
    xpm lexbuf }
  | [^'"']+ {
    (* alles außer strings *)
    xpm lexbuf }
  | '"' [^'"''\\']* '"' {
    (* string *)
    let s = Lexing.lexeme lexbuf  in
    String.sub s 1 ((String.length s)-2) }

and erstezeile =
  parse [' ''\t']+ { erstezeile lexbuf }
  | ['0'-'9']+ { int_of_string (Lexing.lexeme lexbuf) }

and farbzeilenrest =
  parse [' ''\t']+ 'c' [' ''\t']+ { farbzeilenrest lexbuf }
  | "None" { durchsichtig }
  | "Background" { hintergrund }
  | '#' hexziffer hexziffer hexziffer hexziffer hexziffer hexziffer {
    let s = Lexing.lexeme lexbuf  in
    von_rgb (rgbrgb (hexwert s 1) (hexwert s 3) (hexwert s 5)) }


