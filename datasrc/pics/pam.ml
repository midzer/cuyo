(*
   Copyright 2005,2006,2014 by Mark Weyer

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

exception Invalid_PAM

let whitespace = String.contains " \t\n"



type basic_pamdata =
  int * int * int * int *               (* width, height, depth, maxval *)
  int array array array

type pamdata = basic_pamdata * string   (* tuple type *)



let rec read_token line p =
  let rec finish_token q =
    if q=(String.length line)
      then q
      else if whitespace (String.get line q)
        then q
        else finish_token (q+1)  in
  if p=(String.length line)
    then None
    else if whitespace (String.get line p)
      then read_token line (p+1)
      else let p'=finish_token p  in
        Some (String.sub line p (p'-p), p')

let rec tokenize line p =
  match read_token line p  with
    None -> []  |
    Some (t,p') -> t::(tokenize line p')

let rec read_tupletype line p q =
  if p>q
    then ""
    else if whitespace (String.get line p)
      then read_tupletype line (p+1) q
      else if whitespace (String.get line q)
        then read_tupletype line p (q-1)
        else String.sub line p (q-p+1)

let read_headerline channel =
  let line = input_line channel  in
  if (String.length line)=0  then None  else
  if (String.get line 0)='#'  then None  else
  match read_token line 0  with
    None -> None  |
    Some (t,p) -> if t="TUPLTYPE"
      then Some (t::[read_tupletype line p ((String.length line)-1)])
      else Some (t::(tokenize line p))

let read_pamheader channel =
  (* The "P7" of the magic number is already read, the "\n" is not *)
  let magic = input_line channel  in
  if magic<>""  then raise Invalid_PAM  else
  let rec parse_header ll =
    match read_headerline channel  with
      None -> parse_header ll  |
      Some ["ENDHDR"] -> ll  |
      Some l -> parse_header (l::ll)  in
  let header = parse_header []  in
  let find_num token =
    let line = List.find (function [] -> false | h::t -> h=token) header  in
    match line with
      h::n::t -> int_of_string n  in
  let width = find_num "WIDTH"  in
  let height = find_num "HEIGHT"  in
  let depth = find_num "DEPTH"  in
  let maxval = find_num "MAXVAL"  in
  let tuple_type = List.fold_left
    (function sofar -> (function
      [token;value] -> if token="TUPLTYPE"  then value^" "^sofar  else sofar  |
      l -> sofar))
    ""  header  in
  (width,height,depth,maxval,tuple_type)



let rec read_number channel =
  let c = input_char channel  in
  if whitespace c
  then read_number channel
  else
    if c='#'
    then (
      ignore (input_line channel);
      read_number channel)
    else
      let rec read_rest s =
        let c = input_char channel  in
        if whitespace c  then s  else read_rest (s^(String.make 1 c))  in
      int_of_string (read_rest (String.make 1 c))

let read_ppmheader channel =
  let width = read_number channel  in
  let height = read_number channel  in
  let maxval = read_number channel  in
  (width,height,3,maxval,"")

let rec read_string channel num =
  if num=0
    then ""
    else
      let c=input_char channel  in
      (String.make 1 c)^(read_string channel (num-1))

let numbytes n =
  let rec loop bytes maxplus1 = if maxplus1>n
    then bytes
    else loop (bytes+1) (maxplus1*256)  in
  loop 0 1

let read_pam channel =
  match (match read_string channel 2  with
    "P7" -> read_pamheader channel  |
    "P6" -> read_ppmheader channel  |
    s -> raise Invalid_PAM)
  with  width,height,depth,maxval,tuple_type  ->
  let bytes = numbytes maxval  in
  let rec read_sample sample bytes =
    if bytes=0
      then sample
      else read_sample (sample*256+(input_byte channel)) (bytes-1)  in
  let read_sample u = read_sample 0 bytes  in
  ((width,height,depth,maxval,
    Array.init height (function y ->
      Array.init width (function x ->
        Array.init depth read_sample))),
    tuple_type)



let write_pam channel ((width,height,depth,maxval,data),tuple_type) =
  let write_num token num =
    output_string channel (token^" "^(string_of_int num)^"\n")  in
  let bytes = numbytes maxval  in
  let rec write_sample sample bytes =
    if bytes=0
      then ()
      else (write_sample (sample/256) (bytes-1);
        output_byte channel (sample mod 256))  in
  let write_sample sample = write_sample sample bytes  in
  output_string channel "P7\n";
  write_num "WIDTH" width;
  write_num "HEIGHT" height;
  write_num "DEPTH" depth;
  write_num "MAXVAL" maxval;
  output_string channel ("TUPLTYPE "^tuple_type^"\n");
  output_string channel "ENDHDR\n";
  Array.iter (Array.iter (Array.iter write_sample)) data



let pam_channel p (width,height,depth,maxval,data) =
  let rec outdepth sofar n = if n=depth
    then sofar
    else outdepth (if p n  then sofar+1  else sofar) (n+1)  in
  let outdepth = outdepth 0 0  in
  let rec from_channel inn outn = if p inn
    then if outn=0  then inn  else from_channel (inn+1) (outn-1)
    else from_channel (inn+1) outn  in
  let from_channel = from_channel 0  in
  (width,height,outdepth,maxval,
    Array.init height (function y ->
      Array.init width (function x ->
        Array.init outdepth (function n ->
          data.(y).(x).(from_channel n)))))



let pam_stack (width1,height1,depth1,maxval1,data1)
    (width2,height2,depth2,maxval2,data2) =
  (width1,height1,depth1+depth2,maxval1,
    Array.init height1 (function y ->
      Array.init width1 (function x ->
        Array.init (depth1+depth2) (function n ->
          if n<depth1
            then data1.(y).(x).(n)
            else data2.(y).(x).(n-depth1)))))


