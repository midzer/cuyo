(*
   Copyright 2008,2010,2011 by Mark Weyer

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


open Arg


let speclist = ref []

let parse usage =
  let anon = ref []  in
  parse (List.rev !speclist) (fun s -> anon := !anon @ [s]) usage;
  !anon

let usage usage_ = usage (List.rev !speclist) usage_


let register_ref key doc (f : string -> 'a -> 'a) (start : 'a) =
  let res = ref start  in
  speclist := (key, String (fun s -> res := f s !res), doc) :: !speclist;
  res

let register_ref_ignore key doc f =
  register_ref key doc (fun s -> fun _ -> f s)

let register_choices values =
  let res = ref None  in
  speclist := (List.map
    (fun (key,doc) -> (key, Unit (fun () -> res := Some key), doc))
    values) @ !speclist;
  res



module type Parsable = sig  type t  val from_string : string -> t  end
module String = struct  type t=string  let from_string s = s  end

module Int = struct
  type t=int
  let from_string s =
    try int_of_string s
    with Failure "int_of_string" -> raise (Bad "")
end

module Register (T : Parsable) = struct

  let register_without_default key doc =
    register_ref_ignore key doc (fun s -> Some (T.from_string s)) None

  let register_with_default key doc default =
    register_ref_ignore key doc T.from_string default

  let register_list key doc =
    register_ref key doc (fun s -> fun tail -> (T.from_string s) :: tail) []

end

module Register_String = Register(String)
module Register_Int = Register(Int)

let register_int_without_default = Register_Int.register_without_default
let register_string_with_default = Register_String.register_with_default
let register_string_without_default = Register_String.register_without_default

