(*
   Copyright 2011 by Mark Weyer

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

let synopsis () = Sys.argv.(0)^" options gric command"

let outname = Easyarg.register_string_without_default "-o" "Output file name"

let parse_args () =
  try
    let [gric;command] = Easyarg.parse (synopsis ())  in
    let outname = match !outname with
    | None -> command^".xpm"
    | Some s -> s  in
    int_of_string gric, command, outname
  with
  | _ -> (
    Easyarg.usage (synopsis ());
    flush stderr;
    raise (Arg.Bad ""))

