(*
   Copyright 2007 by Mark Weyer

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


type target = string
  (* File name *)
type action = string list
  (* Shell commands *)
type rulespec = target list * target list * action
  (* First targets: Drains. Second targets: Sources.
     (The same order as in traditional makefiles.) *)

val groupaction : action
  (* Special value (actually []) for noop-rules which should not inhibit
     their sources from being counted as final targets. *)

val main : rulespec list -> unit -> unit

