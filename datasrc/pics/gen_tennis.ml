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

open Helfer
open Farbe
open Vektorgraphik
open Male_mit_aa

let pen_thick = 1.0/.32.0
let brick_sep = 1.0/.32.0
let brick_thick = brick_sep
let ball_rad = 0.2
let base_y = 0.35
let source_y = 1.0-.ball_rad-.brick_sep-.brick_thick-.pen_thick
let seq_len = 9
let slf = float_of_int seq_len
let slh = seq_len/2+1
let slhf = float_of_int slh
let g = (source_y-.base_y)/.(slhf*.slhf/.2.0)
let mortar = grau 0.4
let racket_thick = pen_thick*.1.0
let racket_len = base_y-.racket_thick-.pen_thick
let roof_height = 0.5
let brick_height = 1.0/.8.0-.brick_sep
let brick_width = 1.0/.5.0
let sky = rgbrgb 0.0 0.6 1.0

let draw pic w h = male (erzeuge_vektorbild pic) pen_thick
  (Graphik.monochrom durchsichtig w h)

let rect c x0 y0 x1 y1 = flaeche c [konvertiere_polygon [
  Strecke ((x0,y0),(x1,y0));
  Strecke ((x1,y0),(x1,y1));
  Strecke ((x1,y1),(x0,y1));
  Strecke ((x0,y1),(x0,y0));
  ]]

let brick_colour () = von_rgb (rgbrgb
  (0.3+.Random.float 0.3) (0.1+.Random.float 0.2) (Random.float 0.2))

let wall () =
  rect mortar 0.0 0.0 1.0 1.0 ::
  List.concat (List.concat (list_for 0 7 (fun i -> list_for 0 1 (fun j ->
    let y0 = float_of_int i /. 8.0  in
    let y1 = y0 +. brick_height  in
    let x0 = (if j=0  then 0.2  else 0.7) +.
      (if i mod 2 = 0  then 0.0  else 0.25)  in
    let x1 = x0+.0.5-.brick_sep  in
    let c = brick_colour ()  in
    [rect c x0 y0 x1 y1; rect c (x0-.1.0) y0 (x1-.1.0) y1]))))

let source () =
  let circ = konvertiere_polygon
    [Kreis ((0.5,source_y),ball_rad+.brick_thick+.brick_sep)]  in
  [
    Flaechen (
      Array.init 9 (fun i -> if i=0  then mortar  else brick_colour ()),
      (circ,0,None) ::
      list_for 1 8 (fun i ->
        let a1 = pi/.4.0*.(float_of_int i-.0.5) +. brick_sep/.ball_rad/.2.0  in
        let a2 = a1 +. pi/.4.0 +. brick_sep/.ball_rad  in
        konvertiere_polygon [
          Bogen ((0.5,source_y),ball_rad+.brick_thick,true,a1,a2);
          Strecke ((0.5+.cos a2*.ball_rad,source_y+.sin a2*.ball_rad),
            (0.5,source_y));
          Strecke ((0.5,source_y),
            (0.5+.cos a1*.ball_rad,source_y+.sin a1*.ball_rad));
        ],
        i,
        Some 0));
    Strich (mortar,[circ])]

let source_fx source =
  let _,_,source = source  in
  1,1,fun (x,y) ->
    let x' = x-.0.5  in
    let y' = y-.source_y  in
    if x'*.x'+.y'*.y' >= ball_rad*.ball_rad
    then source (x,y)
    else
      let y'' = source_y-.sqrt(ball_rad*.ball_rad-.x'*.x')  in
      misch2 (source (x,y'')) schwarz ((y-.y'')/.(2.0*.ball_rad))

let ball c x y =
  let circ = konvertiere_polygon [Kreis ((x,y),ball_rad)]  in
  let dec = match Random.int 3 with
  | 0 | 1 ->
    let size = 2.0/.3.0  in
    [
    Bogen ((ball_rad*.(1.0+.size)/.2.0,0.0), ball_rad*.(1.0-.size)/.2.0,
      false, 0.0, pi);
    Bogen ((0.0,0.0),ball_rad*.size,true,0.0,1.5*.pi);
    Bogen ((0.0,-.ball_rad*.(1.0+.size)/.2.0), ball_rad*.(1.0-.size)/.2.0,
      false,0.5*.pi,-0.5*.pi);
    ]
  | 2 -> [
    Bogen ((sqrt 2.0*.ball_rad,0.0),ball_rad,true,0.75*.pi,1.25*.pi);
    Bogen ((-.sqrt 2.0*.ball_rad,0.0),ball_rad,true,-0.25*.pi,0.25*.pi);
  ]  in
  let dec = konvertiere_polygon (verschiebe_polygon x y
    (drehe_polygon (Random.float 360.0) dec))  in
  [flaeche c [circ]; Strich (misch2 c schwarz 0.5,[circ; dec])]

let path n c x0 y0 dx dy0 = List.concat (list_for 0 (n-1) (fun i ->
  let i' = float_of_int i  in
  ball c (x0 +. i'*.dx) (y0 +. i'*.dy0 -. i'*.i'*.g/.2.0)))

let suck n c x0 = List.concat (list_for 1 (n-1) (fun i ->
  let i' = float_of_int i  in
  let n' = float_of_int n  in
  ball (misch2 c schwarz (i'/.n')) (x0+.i') (source_y+.i'*.ball_rad*.2.0/.n')))

let wall_aa wall pic =
  let _,_,wall = wall  in
  let w,h,pic = pic  in
  w,h,fun (x,y) ->
    let c = pic (x,y)  in
    let trans = nur_durchsichtig c  in
    if trans=1.0 || trans=0.0
    then c
    else misch2 c (wall (x-.floor x,y-.floor y)) trans

let suck_fx pic =
  let w,h,pic = pic  in
  w,h,fun (x,y) ->
    let x' = x-.floor x-.0.5  in
    if y>source_y+.sqrt((ball_rad+.pen_thick)*.(ball_rad+.pen_thick)-.x'*.x')
    then durchsichtig
    else pic (x,y)

let racket wall ang =
  let y1 = -.racket_len*.0.3  in
  let y2 = -.racket_len  in
  let pic = [
    Dicker_Strich (weiss, racket_thick, [konvertiere_polygon [
      Strecke ((0.0,0.0),(0.0,y1));
      Spline ((0.0,y1),(0.1,y1),(0.1,y2),(0.0,y2));
      Spline ((0.0,y1),(-0.1,y1),(-0.1,y2),(0.0,y2));
    ]]);
  ]  in
  male (erzeuge_vektorbild (verschiebe_dinge 0.5 base_y (drehe_dinge ang pic)))
    pen_thick wall

let rackets wall = Graphik.kombiniere_bildchen 1 3
  (list_for 0 2 (fun i -> 0,i,racket wall (-40.0*.(float_of_int i-.1.0))))

let roof (link_front,link_back) left right =
  let x0 = -0.3  in
  let x1 = x0+.0.5-.brick_sep  in
  let y2 = brick_height+.brick_sep  in
  let y4 = roof_height-.brick_height  in
  let y5 = roof_height-.brick_height/.2.0  in
  let y3 = y5-.brick_sep  in
  List.concat [
    [
      rect mortar 0.0 0.0 1.0 roof_height;
      rect link_back x0 y4 x1 roof_height;
      rect (brick_colour ()) (x0+.0.5) y4 (x1+.0.5) roof_height;
      rect link_back (x0+.1.0) y4 (x1+.1.0) roof_height;
    ];
    if left
    then [
      rect mortar 0.0 y3 brick_width y5;
      rect (brick_colour ()) 0.0 y2 brick_width y3;
    ]
    else [];
    if right
    then [
      rect mortar (1.0-.brick_width) y3 1.0 y5;
      rect (brick_colour ()) (1.0-.brick_width) y2 1.0 y3;
    ]
    else [];
    [
      rect link_front x0 0.0 x1 brick_height;
      rect (brick_colour ()) (x0+.0.5) 0.0 (x1+.0.5) brick_height;
      rect link_front (x0+.1.0) 0.0 (x1+.1.0) brick_height;
    ]
  ]

let roofs links left right c n =
  let roof = roof links left right  in
  let dy0 = float_of_int n*.g/.2.0  in
  Graphik.kombiniere_bildchen n 1 (list_for 0 (n-1) (fun i ->
    let i' = float_of_int i  in
    i,0, draw (roof @ ball c 0.5
        (roof_height/.2.0-.brick_height/.4.0
          +.ball_rad/.sqrt 2.0
          +.dy0*.i'-.i'*.i'*.g/.2.0))
      1 1))

;;

let gric,command,outname = Gen_common.parse_args ()  in
let command = coprefix command 2  in

let base_wall = draw (wall ()) 1 1  in
let source = source_fx (draw (source ()) 1 1)  in
let source_wall = Graphik.ueberlagerung base_wall source None  in
let rooflinks = brick_colour (), brick_colour()  in

let colours = [
  "Blue", (1000, von_rgb (rgbrgb 0.1 0.2 1.0));
  "Grey", (2000, grau 0.6);
  "Green", (3000, von_rgb (rgbrgb 0.3 1.0 0.0));
  "Yellow", (4000, von_rgb (rgbrgb 1.0 0.9 0.0));
]  in

let colour name = snd (List.assoc name colours)  in

let skip,pic = match command with
| "Wall" -> 0,(fun () -> base_wall)
| "Source" -> 0,(fun () -> wall_aa base_wall source)
| "Racket" -> 100,(fun () -> rackets base_wall)
| "Roof1" -> 200,(fun () -> roofs rooflinks true true (colour "Yellow") 5)
| "Roof2" -> 300,(fun () -> roofs rooflinks true false (colour "Grey") 7)
| "Roof3" -> 400,(fun () -> roofs rooflinks false false (colour "Green") 5)
| "Roof4" -> 500,(fun () -> roofs rooflinks false true (colour "Blue") 7)
| _ ->
  let cn,(s,c) = List.find
    (fun (n,_) -> prefix command (String.length n) = n)
    colours  in
  (match coprefix command (String.length cn) with
  | "Bounce" -> s, fun () -> wall_aa base_wall
    (draw (path seq_len c 0.5 base_y 1.0 (slf/.2.0*.g)) seq_len 1)
  | "Left" -> s+100, fun () -> wall_aa base_wall
    (draw (path seq_len c 1.5 (1.0+.base_y)
      (2.0-.1.0/.slf) (slf/.2.0*.g-.1.0/.slf)) (2*seq_len) 2)
  | "Right" -> s+200, fun () -> wall_aa base_wall
    (draw (path seq_len c 0.5 (1.0+.base_y)
      (2.0+.1.0/.slf) (slf/.2.0*.g-.1.0/.slf)) (2*seq_len) 2)
  | "Out" -> s+300, fun () -> wall_aa source_wall
    (suck_fx (draw
      (path (slh+1) c 0.5 base_y 1.0 (g*.slhf) @
        (suck (seq_len-slh) c (slhf+.0.5)))
      seq_len 1))
  )  in

for i=1 to skip do
  ignore (Random.int 2);
done;

Graphik.gib_xpm_aus sky outname (Graphik.berechne gric (pic ()))

