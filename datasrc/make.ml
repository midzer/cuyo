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

exception Multi_Rules of string
exception Circular_Rules of string
exception Missing_Source of string
exception Command_Error of string * int


module Int = struct type t=int  let compare=compare end
module IntMap = Map.Make(Int)

type target = string

module Target = struct type t=target  let compare a b = compare b a end
  (* Reverse order so that animation sequences are made in right order. *)
module TargetSet = Set.Make(Target)
module TargetMap = Map.Make(Target)


type action = string list
  (* List of shell commands to execute *)

let groupaction = []

type rulespec = target list * target list * action

type rule = TargetSet.t * action * TargetSet.t
  (* First set: sources. Second set: drains.
     (A different order than rulespec, but the more usual direction for
     arrows.) *)

type rules = rule array

type rulemap = int TargetMap.t
  (* The int is an index into rules.
     The map itself is indexed from drains. *)



let set_from_list = List.fold_left
  (fun set -> fun element -> TargetSet.add element set)
  TargetSet.empty

let rules_from_rulespecs data = Array.of_list (List.map
  (fun (drains,sources,action) ->
    set_from_list sources, action, set_from_list drains)
  data)

let sets rules = Array.fold_left
    (* Computes the overall sets of sources and of drains. *)
  (fun (sources,drains) -> fun (source,action,drain) ->
    TargetSet.union sources source,  TargetSet.union drains drain)
  (TargetSet.empty,TargetSet.empty)
  rules

let rulemap rules = fst (Array.fold_left
  (fun (map,i) -> fun (sources,action,drains) ->
    TargetSet.fold
      (fun drain -> fun map -> if TargetMap.mem drain map
        then raise (Multi_Rules drain)
        else TargetMap.add drain i map)
      drains
      map,
    i+1)
  (TargetMap.empty,0)
  rules)



let dag_compute
  (startside : int -> 'side_info)
  (merge : 'target_info -> 'side_info -> 'side_info)
  (endside : int -> 'side_info -> 'rule_info)
  (leaf : target -> 'target_info)
  (nonleaf : target -> 'rule_info -> 'target_info)
  rules
  rulemap
  targets =
      (* The rules define a bipartite dag between targets and rules:
         Each target has an edge to the rule producing it, if such a rule
         exists, and each rule has edges to all its sources.

         In a bottom-up fashion this function computes the 'target_info for
         each target and the 'rule_info for each rule. More specifically the
	 computation is restricted to the part of the dag below targets.
	 The 'target_infos of a node's children are merged into a 'rule_info
         in a sideways computation.

         For each node the computation is done only once, not once per path
         leading there.

         If rulemap does not define a dag, Circular_Rules is raised.

         The result is of type 'target_info TargetMap.t * 'rule_info IntMap.t
      *)

    let rec compute targetresults ruleresults path target =
      if TargetSet.mem target path
      then raise (Circular_Rules target)
      else if TargetMap.mem target targetresults
        then TargetMap.find target targetresults, targetresults, ruleresults
        else if TargetMap.mem target rulemap
          then
            let index = TargetMap.find target rulemap  in
            if IntMap.mem index ruleresults
            then
	      let value = nonleaf target (IntMap.find index ruleresults)  in
	      value, TargetMap.add target value targetresults, ruleresults
            else
              let path = TargetSet.add target path  in
              let sources,action,drains = rules.(index)  in
              let side,targetresults,ruleresults = TargetSet.fold
                (fun source -> fun (side,targetresults,ruleresults) ->
                  let value,targetresults,ruleresults = compute
                    targetresults ruleresults path source  in
                  merge value side, targetresults, ruleresults)
	        sources
                (startside index, targetresults, ruleresults)  in
              let value = endside index side  in
	      let ruleresults = IntMap.add index value ruleresults  in
              let value = nonleaf target value  in
              value, TargetMap.add target value targetresults, ruleresults
          else
            let value = leaf target  in
	    value, TargetMap.add target value targetresults, ruleresults  in

    TargetSet.fold
      (fun target -> fun (targetresults,ruleresults) ->
	let value,targetresults,ruleresults = compute
          targetresults ruleresults TargetSet.empty target  in
        targetresults, ruleresults)
      targets
      (TargetMap.empty, IntMap.empty)



let check rules =
  let _,drains = sets rules  in
  ignore (dag_compute
      (* All infos are unit. We just check for dagness. *)
    (fun _ -> ())
    (fun _ -> fun _ -> ())
    (fun _ -> fun _ -> ())
    (fun _ -> ())
    (fun _ -> fun _ -> ())
    rules  (rulemap rules)  drains)

let print_rules = Array.iter
  (fun (sources,action,drains) ->
    TargetSet.iter (fun drain -> print_string (drain^" ")) drains;
    print_string "<--";
    TargetSet.iter (fun source -> print_string (" "^source)) sources;
    print_string "\n")



type time = float option
  (* File modification time, None if file does not exist *)

let time file = if Sys.file_exists file
  then Some ((Unix.stat file).Unix.st_mtime)
  else None

let newer time1 time2 = match time1  with
  | None -> false
  | Some t1 -> (match time2  with
    | None -> true
    | Some t2 -> t1>=t2)

let newest time1 time2 = if newer time1 time2  then time1  else time2

let echo_action drains line = print_string (line^"\n"); flush stdout
let run_action drains line =
  let error = Sys.command line  in
  if error != 0  then (
      (* Delete drains, then raise exception. *)
    if not (TargetSet.is_empty drains)
    then ignore (Sys.command ("rm -f "^(TargetSet.fold
      (fun target -> fun targets -> targets^" "^target)
      drains
      "")));
    raise (Command_Error (line,error)))
let echorun_action drains line =
  echo_action drains line;
  run_action drains line

let make execute rules targets =
    (*
       A file is relevant, if it is a source of a file from targets.
       A file is important, if it exists or if it is from targets.
       A file is out-of-date, if one of its sources is newer.
       A file needs to be rebuilt, if one of the following holds:
       1 It is relevant, important, and out_of_date.
       2 It is relevant and one of its sources needs to be rebuilt.
       3 It does not exist and one of its direct drains needs to be rebuilt.
       A rule is executed, if one of its direct drains needs to be rebuilt.

       We first compute the set of targets that need to be rebuilt according
       to 1 and 2. In a second pass, the rules are actually executed. As the
       criterion 3 neccessitates reentry of subdags, the second pass is not
       implemented with dag_compute (it does however enter each subdag at most
       once - just not neccessarily on the first encounter).
    *)

  let rulemap = rulemap rules  in
  let targetresults,ruleresults = dag_compute
      (* All 'infos are time * bool:
         Newest strictly decending file and need to rebuild. *)
    (fun i -> None,false)
    (fun (newest1,rebuild1) -> fun (newest2,rebuild2) ->
      newest newest1 newest2, rebuild1 || rebuild2)
    (fun i -> fun info -> info)
    (fun target ->
      let time = time target  in
      if time=None
      then raise (Missing_Source target)
      else (time,false))
    (fun target -> fun (newest,rebuild) ->
      let time = time target  in
      if newer time newest
      then (time, rebuild)
      else (newest, rebuild || time!=None || TargetSet.mem target targets))
    rules  rulemap  targets  in

  let rec build target done_ =
    let _,rebuild = TargetMap.find target targetresults  in
    if ((time target)=None || rebuild) && not (TargetSet.mem target done_)
    then (
      let index = TargetMap.find target rulemap  in
      let sources,action,drains = rules.(index)  in
      let done_ = TargetSet.fold
        (fun source -> fun done_ -> build source done_)
        sources
        done_  in
      List.iter (execute drains) action;
      TargetSet.union drains done_)
    else done_  in

  ignore (TargetSet.fold
    (fun target -> fun done_ ->
      if snd (TargetMap.find target targetresults)
      then build target done_
      else done_)
    targets
    TargetSet.empty)



let final rules rulemap targets =
    (* Computes the set of targets that are linked to targets
       only by group rules. *)
  let targetresults,_ = dag_compute
      (* 'target_info = 'side_info = TargetSet.t and
	 'rule_info = TargetSet.t option.
	 None means that the rule has a non-group action. *)
    (fun _ -> TargetSet.empty)
    TargetSet.union
    (fun index -> fun sources_targets ->
      let sources,action,drains = rules.(index)  in
      if action = groupaction
      then Some sources_targets
      else None)
    TargetSet.singleton
    (fun target -> fun sources_targets -> match sources_targets  with
    | None -> TargetSet.singleton target
    | Some targets -> targets)
    rules  rulemap  targets  in
  TargetSet.fold
    (fun target -> fun final ->
      TargetSet.union final (TargetMap.find target targetresults))
    targets
    TargetSet.empty

let initial rules rulemap targets =
    (* Computes the set of leaf targets on which targets strictly depend
       (If there happens to be no rule for a file in targets, this is no
       sufficient reason to include it.). *)
  let targetresults,_ = dag_compute
      (* 'rule_info = 'side_info = TargetSet.t
         'target_info = target option * TargetSet.t
         The reason for the specialness of 'target_info is, that we do
         not want the given targets to appear in the output list. *)
    (fun _ -> TargetSet.empty)
    (fun (target,initial1) -> fun initial2 ->
      let initial = TargetSet.union initial1 initial2  in
      match target  with
      |	None -> initial
      |	Some target -> TargetSet.add target initial)
    (fun _ -> fun initial -> initial)
    (fun target -> Some target, TargetSet.empty)
    (fun _ -> fun targets -> None, targets)
    rules  rulemap  targets  in
  TargetSet.fold
    (fun target -> fun initial ->
      TargetSet.union initial (snd (TargetMap.find target targetresults)))
    targets
    TargetSet.empty

let decendants rules rulemap targets =
  let targetresults,_ = dag_compute
      (* All 'infos are TargetSet.t. *)
    (fun _ -> TargetSet.empty)
    TargetSet.union
    (fun _ -> fun sources -> sources)
    TargetSet.singleton
    TargetSet.add
    rules  rulemap  targets  in
  TargetSet.fold
    (fun target -> fun decendants ->
      TargetSet.union decendants (TargetMap.find target targetresults))
    targets
    TargetSet.empty



let strippath file = if String.contains file '/'
  then
    let pos = (String.rindex file '/')+1  in
    String.sub file pos ((String.length file)-pos)
  else file

let stripgz file =
  let l = String.length file  in
  if l<3
  then file
  else if String.sub file (l-3) 3 = ".gz"
    then String.sub file 0 (l-3)
    else file

let list = TargetSet.iter (fun target -> print_string (target^"\n"))


let dist rules targets =
  let stripped = TargetSet.fold
    (fun target -> fun stripped ->
      TargetSet.add (strippath (stripgz target)) stripped)
    targets
    TargetSet.empty  in
  list (initial rules (rulemap rules) stripped)

let expandgroups rules targets = list (final rules (rulemap rules) targets)

let intermediate rules targets =
  let sources,drains = sets rules  in
  let final = final rules (rulemap rules) targets  in
  list (TargetSet.diff drains final)

let sources rules =
  let sources,drains = sets rules  in
  list (TargetSet.diff sources drains)



let parseargs u =
    (* Turns the args into (string * string option * TargetSet.t).
       The string is the command name without directory info.
       The string option is the first arg (if existent).
       The set contains the other args. *)
  let args = Array.length Sys.argv  in
  if args=0
  then  (* This is really weird, but we play along as best as we can... *)
    "<this program>", None, TargetSet.empty
  else
    let command = Sys.argv.(0)  in
    let stripped = strippath command  in
    if args>1
    then
      let rec collect targets i = if i=args
      then targets
      else collect (TargetSet.add Sys.argv.(i) targets) (i+1)  in
      (stripped, Some Sys.argv.(1), collect TargetSet.empty 2)
    else (stripped, None, TargetSet.empty)


let main rules' u =
  try
    let rules = rules_from_rulespecs rules'  in
    let call,command,targets = parseargs ()  in
    match command  with
    | None -> prerr_string (
      "Usage:\n\n"^
      call^" [command] [target1] [target2] ...\n\n"^
      "commands:\n"^
      "check:\tCheck all rules for cyclic dependencies.\n"^
      "dist:\tList the non-intermediate sources for the given targets.\n"^
      "expand:\tList the given targets after expanding groups.\n"^
      "intermediate:\tList all generated files except those given by the expand command.\n"^
      "print:\tMake targets, but print commands instead of executing them.\n"^
      "rules:\tPrint all rules.\n\n"^
      "sources:\tList all non-intermediate sources.\n"^
      "Without any command, the targets are made according to the rules.\n"^
      "Without any command or targets, this message is printed to stderr.\n")
    | Some "check" -> check rules
    | Some "dist" -> dist rules targets
    | Some "expand" -> expandgroups rules targets
    | Some "intermediate" -> intermediate rules targets
    | Some "print" -> make echo_action rules targets
    | Some "rules" -> print_rules rules
    | Some "sources" -> sources rules
    | Some target -> make echorun_action rules (TargetSet.add target targets)
  with
  | Multi_Rules target -> prerr_string
    ("Rule error: There are multiple rules to generate "^target^".\n")
  | Circular_Rules target -> prerr_string
    ("Rule error: There is a cyclic chain of rules involving "^target^".\n")
  | Missing_Source target -> prerr_string
    ("Error: File "^target^
      " does not exist and there is no rule to generate it.\n")
  | Command_Error (command, exitcode) -> prerr_string
    ("Error: Received exit code "^(string_of_int exitcode)^
      " when executing the following command:\n  "^command^"\n")


