(*
   Copyright 2011 by Mark Weyer
   Partly based on machxpm.ml which, at that time, was
     Copyright 2006-2008,2010,2011 by Mark Weyer

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

let outname = Easyarg.register_string_without_default "-o"
  "Output file name. Defaults to infile.xpm"

let synopsis =  "machppm options infile"

;;

let anon = Easyarg.parse synopsis in

let inname = match anon  with
| [name] -> name
| _ -> (Easyarg.usage synopsis; raise (Arg.Bad ""))  in

let outname = match !outname with
| None -> inname^".ppm"
| Some name -> name  in

let bild = Graphik.lies_xpm (inname^".xpm")  in

Graphik.gib_ppm_aus outname bild

