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

(*
   The purpose of this module is providing an easy interface to parsing
   of command line option. Under the hood, the standard module Arg is
   used.

   Note that this is an object module, not a type module: Internally,
   it uses global data. I consider this OK in this specific case, because
   it can be seen as just extending the functionality of Sys.argv, which
   is global anyway.

   Abbreviations used below:
   CL := command line
   CLO := command line option
*)


val parse : string -> string list
  (* This should be called after everything else.
     The string is the overall usage description.
     The string list consists of those parts of Sys.argv
     which could not be identified as CLOs. *)

val usage : string -> unit
  (* This can be used to report errors which were not caught by parse.
     The string is as in parse. *)


(* The register_* functions all tell this module to introduce a CLO
   with the given name and doc. The return value is a reference, into
   which a subsequent call to parse stores the result.
   If a CLO occurs more than once on the CL, usually the last value
   is taken. *)

val register_choices : (Arg.key * Arg.doc) list -> Arg.key option ref
  (* The entries in the given list are mutually exclusive switches
     without a data type. The value is the switch chosen at the CL,
     with "None" meaning, well, that none occured. *)

module type Parsable = sig  type t  val from_string : string -> t  end

module Register (T:Parsable) : sig

  val register_without_default : Arg.key -> Arg.doc -> T.t option ref
    (* A value "None" means, that the CLO did not occur at the CL. *)
  val register_with_default : Arg.key -> Arg.doc -> T.t -> T.t ref
  val register_list : Arg.key -> Arg.doc -> T.t list ref
    (* This one collects all occurences of the CLO. *)

end

(* For convenience, some values of instantiations of the Register functor
   are supplied in the following. *)

val register_int_without_default : Arg.key -> Arg.doc -> int option ref
val register_string_with_default : Arg.key -> Arg.doc -> string -> string ref
val register_string_without_default : Arg.key -> Arg.doc -> string option ref

