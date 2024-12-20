(*
   Copyright 2007-2011,2014 by Mark Weyer

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


open Make


(*===========================================================================*)

let gric = 32  (* Not everything respects gric changes *)

let ml_graphik = ["helfer";"pam";
  "natmod";"vektor";"farbe";"xpmlex";"graphik"]
let ml_gen_whatever = "easyarg"::"gen_common"::ml_graphik
let ml_vektorgraphik = ml_gen_whatever @ ["polynome"; "vektorgraphik"]



let colour colour none some = match colour  with
  | None -> none
  | Some (r,g,b) -> some^" "^
      (string_of_int r)^"/"^(string_of_int g)^"/"^(string_of_int b)^" "


let digits_num digits a =
  let s = string_of_int a  in
  let missing = digits-(String.length s)  in
  (String.make (max 0 missing) '0')^s

let rec num_anim digits a b = if a>b
  then []
  else (digits_num digits a)::(num_anim digits (a+1) b)

let combine_anim left right = List.concat (List.map
  (fun a -> List.map ((^)a) right)
  left)

let fill_anim left stages right = List.map
  (fun stage -> left^stage^right)
  stages



let group file files = [[file],files,groupaction]

let xgz file = [[file^".xpm.gz"], [file^".xpm"],
  ["gzip -c -f -n "^file^".xpm > "^file^".xpm.gz"]]

let xzgroup file files = List.concat [
  group file (fill_anim "" files ".xpm.gz");
  List.concat (List.map xgz files);
  ]

let xpm_of_rgba ?(quant_colours=None) ?(quant_method="maximal") file = [
  [file^".xpm"],
  [file^".pam"; "machxpm"],
  ["./machxpm -rgba "^
    (match quant_colours  with
    | None -> ""
    | Some n -> "-colours "^(string_of_int n))^
    " -"^quant_method^
    " "^file]]

let xpm_of_rgbas ?(quant_colours=None) ?(quant_method="maximal")
    width files file =
  [
    [file^".xpm"],
    "machxpm" :: List.map (fun f -> f^".pam") files,
    ["./machxpm -rgba "^
      (match quant_colours  with
      | None -> ""
      | Some n -> "-colours "^(string_of_int n))^
      " -"^quant_method^
      " -width "^(string_of_int width)^
      " -o "^file^".xpm "^
      String.concat " " files]]

let pam_of_ppmpgm file = [
  [file^".pam"],
  [file^".ppm"; file^".umriss.pgm"],
  ["pamarith -multiply "^file^".ppm "^file^".umriss.pgm "^
      "| pamstack - "^file^".umriss.pgm > "^file^".pam"]]

let pgm_of_ppm file = [
  [file^".pgm"],
  [file^".ppm"],
  ["ppmtopgm "^file^".ppm | pamfunc -multiplier 255 > "^file^".pgm"]]

let pam_of_ppm2 file = List.concat [
    pgm_of_ppm (file^".umriss");
    pam_of_ppmpgm file;
  ]

let xpm_of_ppm2 quant_colours quant_method file =
  List.concat [
    pam_of_ppm2 file;
    xpm_of_rgba ~quant_colours:quant_colours ~quant_method:quant_method file;
  ]

let ppm_of_pov width height aa extra file includes =
  let w,h = width*gric, height*gric  in
  let ws,hs = string_of_int w, string_of_int h  in
  [
    (* The antialiasing argument aa is:
         None for no antialiasing
         Some true for antialising which respects pixel boundaries
         Some false for antialising which does not respect pixel boundaries *)
  [file^".ppm"],
  [file^".pov";"version.inc"]@includes,
  ["povray +FP -D -w"^ws^" -h"^hs^
      (match aa with
      |	None -> ""
      |	Some true -> " +A +AM1 -J"
      |	Some false -> " +A +AM2 +R2 -J")^
      " +HIversion.inc"^
      " "^extra^
      " "^file^".pov";
    "test -e "^file^".ppm";
  ]]

let ppm_of_pov_umriss width height aa extra file includes =
  let w,h = width*gric, height*gric  in
  let ws,hs = string_of_int w, string_of_int h  in
  [
    (* The antialiasing argument aa is:
         None for no antialiasing
         Some true for antialising which respects pixel boundaries
         Some false for antialising which does not respect pixel boundaries *)
  [file^".umriss.ppm"],
  [file^".pov";"umriss.inc"]@includes,
  ["povray +FP -D -w"^ws^" -h"^hs^
      (match aa with
      |	None -> ""
      |	Some true -> " +A +AM1 -J"
      |	Some false -> " +A +AM2 +R2 -J")^
      " +HIumriss.inc"^
      " -O"^file^".umriss.ppm"^
      " "^extra^
      " "^file^".pov";
    "test -e "^file^".umriss.ppm";
  ]]

let pam_of_pov width height aa extra file includes =
  let includes = "cuyopov.inc"::includes  in
  List.concat [
    ppm_of_pov width height aa extra file includes;
    ppm_of_pov_umriss width height aa extra file includes;
    pam_of_ppm2 file;
  ]

let xpm_of_pov_trans width height ?(aa=Some false) ?(extra="")
    ?(quant_colours=None) ?(quant_method="maximal") file includes =
  List.concat [
    pam_of_pov width height aa extra file includes;
    xpm_of_rgba ~quant_colours:quant_colours ~quant_method:quant_method file;
  ]

let xpm_of_ppm trans_colour ?(forced_pixels=[]) quant_colours quant_method
    file = [
  [file^".xpm"],
  [file^".ppm"; "machxpm"],
  ["./machxpm -ppm "^
    (List.fold_left
      (fun s -> fun (x,y) ->
        s^"-includepixelcolour "^string_of_int x^"/"^string_of_int y^" ")
      ""
      forced_pixels)^
    (colour trans_colour "" "-transcolour")^
    (match quant_colours  with
    | None -> ""
    | Some n -> "-colours "^(string_of_int n))^
    " -"^quant_method^
    " "^file]]

let xpm_of_pov width height ?(aa=Some false) ?(extra="") ?(trans_colour=None)
     ?(forced_pixels=[]) ?(quant_colours=None) ?(quant_method="maximal")
     file includes =
  List.concat [
    ppm_of_pov width height aa extra file includes;
    xpm_of_ppm trans_colour
      ~forced_pixels:forced_pixels quant_colours quant_method file;
  ]

let stuff_of_prog files prog ?(extradepends=[]) options = [
  files,
  prog::extradepends,
  ["./"^prog^" "^options]]

let ml_prog file includes =
  let endings ending = List.map (fun include_ -> include_^ending) includes  in
  [
    [file; file^".cmx"; file^".cmi"; file^".o"],
    (file^".ml")::(endings ".cmi")@(endings ".cmx"),
    ["ocamlopt.opt -o "^file^
      (List.fold_left (fun l -> fun r -> l^" "^r^".cmx") "" includes)^
      " "^file^".ml"]]

let stuff_of_ml targets prog ?(options="") includes = List.concat [
    stuff_of_prog targets prog options;
    ml_prog prog includes;
  ]

let group_of_ml name ?(extratargets=[]) ?(extradepends=[]) targets includes =
  let progname = "gen_"^name  in
  List.concat [
    xzgroup name (extratargets @ targets);
    ml_prog progname includes;
    List.concat (List.map
      (fun target -> stuff_of_prog [target^".xpm"] progname
        ~extradepends:extradepends
        ((string_of_int gric)^" "^target))
      targets);
  ]

let ml_module file includes =
  let endings ending = List.map (fun include_ -> include_^ending) includes  in
  [
    [file^".cmi"],
      (file^".mli")::(endings ".cmi"),
      ["ocamlopt.opt "^file^".mli"];
    [file^".cmx"; file^".o"],
      (file^".ml")::(file^".cmi")::(endings ".cmi")@(endings ".cmx"),
      ["ocamlopt.opt -c "^file^".ml"];
  ]

let recolour source drain colour' = [
  [drain^".xpm"],
  [source^".xpm"; "machxpm"],
  ["./machxpm -xpm -recolour "^(colour colour' "trans " "")^
    " -o "^drain^".xpm"^" "^source]]

let pov_fill2 source drain povvar value stage = [
  [drain^stage^".pov"],
  [source^".pov"],
  ["echo \"#declare "^povvar^"="^value^";\" "^
    "| cat - "^source^".pov > "^drain^stage^".pov"]]

let pov_fill file povvar stage = pov_fill2 file file povvar stage stage

let xpm_of_pov_fill_trans width height ?(aa=Some false) ?(extra="")
    ?(quant_colours=None) ?(quant_method="maximal") file includes
    povvar stages = List.concat (List.map
  (fun stage -> List.concat [
    xpm_of_pov_trans width height ~aa:aa ~extra:extra
      ~quant_colours:quant_colours ~quant_method:quant_method
      (file^stage) includes;
    pov_fill file povvar stage])
  stages)

let xpm_of_pov_fill width height ?(aa=Some false) ?(extra="")
    ?(trans_colour=None)
    ?(forced_pixels=[]) ?(quant_colours=None) ?(quant_method="maximal")
    file includes povvar stages = List.concat (List.map
  (fun stage -> List.concat [
    xpm_of_pov width height ~aa:aa ~extra:extra ~trans_colour:trans_colour
      ~forced_pixels:forced_pixels ~quant_colours:quant_colours
      ~quant_method:quant_method
      (file^stage) includes;
    pov_fill file povvar stage])
  stages)

let gimp_script_xpm_of_xcf threshold used_layers srcname dstname =
  "(let* (" ^
    "(image (car (gimp-xcf-load 0 \"" ^ srcname ^ "\" \"" ^ srcname ^ "\")))" ^
    "(layers_with_num (gimp-image-get-layers image))" ^
    "(num_layers (car layers_with_num))" ^
    "(layers (cadr layers_with_num))" ^
    "(current_layer 0)" ^
    "(used_layers (list " ^
      String.concat " " (List.map string_of_int used_layers) ^ " 10000000))" ^
    "(visible TRUE)" ^
    ")" ^
  "(while (< current_layer num_layers)" ^
    "(if (= current_layer (car used_layers))" ^
      "(set! visible TRUE)" ^
      "(set! visible FALSE))" ^
    "(gimp-item-set-visible (aref layers current_layer) visible)" ^
    "(if (= visible TRUE) (set! used_layers (cdr used_layers)))" ^
    "(set! current_layer (+ current_layer 1))" ^
    ")" ^
  "(file-xpm-save RUN-NONINTERACTIVE image" ^
    "(car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE))" ^
    "\"" ^ dstname ^ "\" \"" ^ dstname ^ "\" " ^ string_of_int threshold^ "))" ^
  "(gimp-quit TRUE)"

let xpm_of_xcf ?(threshold=127) used_layers ?srcname dstname =
  let srcname = match srcname with
  | None -> dstname
  | Some s -> s  in
  let srcname = srcname ^ ".xcf"  in
  let dstname = dstname ^ ".xpm"  in
  [
    [dstname],
    [srcname],
    ["gimp -i -d -f -b '" ^
      gimp_script_xpm_of_xcf threshold used_layers srcname dstname ^ "'"]]

let xpms_of_xcf ?threshold srcname specs = List.concat (List.map
  (fun (dstname,used_layers) ->
    xpm_of_xcf ?threshold used_layers ~srcname:srcname dstname)
  specs)

(*===========================================================================*)

let rules = List.concat [

    group "all"
      ["aehnlich"; "angst"; "augen"; "aux"; "bonimali";
        "bunt"; "dungeon"; "fische"; "flechtwerk"; "fractals"; "jump";
        "kacheln"; "kolben"; "novips";
        "octopi"; "puzzle"; "rechnen"; "reversi_brl";
        "rollenspiel"; "schemen"; "secret"; "slime";
        "tennis"; "trees"; "xcf"; "zahn"; "ziehlen"];


    xzgroup "aehnlich" ["maeSorten"; "maeSchema"];
    xpm_of_pov_trans 2 2 "maeSchema" ["aehnlich.inc"];
    xpm_of_pov_trans 7 14 ~quant_colours:(Some 400)
      "maeSorten" ["aehnlich.inc"];


    group_of_ml "augen" (fill_anim "ma"
        (fill_anim "Lid" ["A";"B";"C";"D"] "" @ num_anim 1 1 5)
        "")
      ml_vektorgraphik;

    group_of_ml "angst"
      (fill_anim "man" ("Gras"::"Grau"::
        combine_anim ["Koepfe";"Gesichter"] (num_anim 1 1 7)) "")
      ml_vektorgraphik;


    (* bonimali *)
    (let uhrdinge = [
      "Ketten"; "Kurz"; "Langsam"; "Lang"; "Minus"; "Octi"; "Schnell";
      "Ununterscheidbar"
      ]  in
    group_of_ml "bonimali"
      ~extratargets:["mbmGras";"mbmGrau"]
      ~extradepends:["mbmGras.xpm";"mbmGrau.xpm"]
      (fill_anim "mbm"
        ([
          "GrauGras"; "GrauJoker"; "Leben"; "Punkte"; "Raketen"; "Verschwind";
          ] @ uhrdinge @
        (fill_anim "" uhrdinge "Uhr")) "")
      ml_vektorgraphik);


    xzgroup "aux" ["font-big"; "highlight"; "feenstaub"];
    xpm_of_rgba "font-big";
    [["font-big.pam"],
      ["font-orig.png";"genSchrift"],
      ["./genSchrift -font font-orig.png font-big.pam"]];
    [["genSchrift"],
      ["genSchrift.cc"],
      ["g++ -g genSchrift.cc -L../lib -lSDL -lSDL_image -lm"^
          " -I../include -I/usr/include/SDL -O2 -o genSchrift"]];
    stuff_of_ml ["feenstaub.xpm"] "feenstaub" ml_gen_whatever;
    stuff_of_ml ["highlight.xpm"] "highlight"
      ~options:(string_of_int gric) ml_gen_whatever;


    (* bunt *)
    (let schmelz = num_anim 1 1 4  in
    List.concat [
      xzgroup "bunt" (["mbUnbunt";"mbBunt"]@
        (fill_anim "mbSchmelz" schmelz ""));
      xpm_of_pov_trans 17 1 ~quant_colours:(Some 512) "mbUnbunt" ["bunt.inc"];
      xpm_of_pov_trans 17 8 ~quant_colours:(Some 512) "mbBunt" ["bunt.inc"];
      xpm_of_pov_fill_trans 16 32 ~quant_colours:(Some 512)
        "mbSchmelz" ["bunt.inc"] "Schritt" schmelz;
    ]);


    (* dungeon

       Damit niemand denkt, das Ausschalten von antialiasing (~aa:None)
       sei aus Angst vor der Rechenzeit geschehen: Es ist völlig normal,
       daß sich die Graphiken überlappen, so daß antialiasing gegen
       irgendeine feste Farbe immer falsch ist.
    *)
    (let farben31 =
      ["Ziegel"; "Holz"; "Eisen"; "Stein"; "Fels"]  in
    let farben11 =
      ["EgoV"; "EgoH"; "EgoL"; "EgoR"]  in
    let farben = "Plastik"::"Gold"::farben31@farben11  in
    let boden = num_anim 2 0 15  in
    let ziele = num_anim 2 0 11  in
    let render = num_anim 3 0 34  in
    let render4 = [(0,[1]); (1,[0;2]); (2,[3;5;7]); (3,[4;6])]  in
    let render3 = [(4,[8;11;14]); (5,[9;12]); (6,[10;13]);
      (7,[15;17;19;21;23]); (8,[16;18;20;22])]  in
    let render2 = [(9,[24;27;29;31;34]); (10,[25;28;32]); (11,[26;30;33])]  in
    let himmel = num_anim 1 0 3  in
    let includes farbe =
      ["dungeon_boden.inc"; "dungeon.inc"] @
      match farbe with
      | "Gold" -> ["mdGold.inc"; "cuyo.ppm"]
      | "EgoV" | "EgoH" | "EgoL" | "EgoR" ->
          ["mdEgo.inc"; "mdAuge.ppm"; "mdEgoHaare.data"]
      | _ -> []  in
    let gruppe farbe ziel liste =
      let name nummer = "md"^farbe^nummer^".pam"  in
      [name ziel],
      List.map name liste,
      match liste with
      | [quelle] ->
        ["cp "^(name quelle)^" "^(name ziel)]
      | quelle1::rest -> [(List.fold_left
          (fun bisher -> fun quelle ->
            bisher^" | pamarith -add "^(name quelle)^" -")
          ("cat "^(name quelle1))
          rest) ^
        " > "^(name ziel)]  in
    let sequenz farbe height extra liste = List.concat (List.map
      (fun (ziel,teile) ->
	let ziel = digits_num 2 ziel  in
        let teile = List.map (digits_num 3) teile  in
        List.concat [
          [gruppe farbe ziel teile];
          List.concat (List.map
            (fun teil -> pam_of_pov 4 height None extra
              ("md"^farbe^teil) (includes farbe))
            teile);
            xpm_of_rgba ("md"^farbe^ziel);
      ])  liste)  in
    let draufseite width draufheight draufversionen seitenversionen farben =
      List.concat (List.map
        (fun farbe ->
          let zeile versionart v0 v1 h = List.concat (List.map
            (fun version -> List.concat [
              pam_of_pov 1 h None ""
                ("md"^farbe^version) (includes farbe);
              pov_fill ("md"^farbe) versionart version;
              ])
            (num_anim 1 v0 v1))  in
          List.concat [
            xpm_of_rgbas (width*gric)
              (List.map (fun v -> "md"^farbe^v)
                (num_anim 1 0 (draufversionen+seitenversionen-1)))
              ("md"^farbe);
            zeile "DraufVersion" 0 (draufversionen-1) draufheight;
            zeile "SeitenVersion" draufversionen
              (draufversionen+seitenversionen-1) 1;
            ])
        farben)  in
    List.concat [
      group "dungeon" (fill_anim "dungeon" ("Boden"::"Himmel"::farben) "");
      group "dungeonEgo" (fill_anim "dungeonEgo" ["V";"H";"L";"R"] "");
      xzgroup "dungeonBoden" (fill_anim "mdBoden" (""::boden) "");
      xzgroup "dungeonHimmel" (fill_anim "mdHimmel" himmel "");
      draufseite 3 2 3 3 farben31;
      draufseite 2 2 4 0 farben11;
      draufseite 2 2 4 1 ["Gold"];
      draufseite 2 1 6 0 ["Plastik"];
      xpm_of_pov 1 1 ~aa:(Some true) "mdBoden" (includes "Boden");
      xpm_of_pov_fill 4 2 "mdHimmel" (includes "Himmel")
        "HimmelVersion" himmel;
      xpm_of_pov_fill 4 2 ~aa:None ~extra:"-UV" ~forced_pixels:[0,0]
        "mdBoden" (includes "Boden") "BodenVersion" boden;
      List.concat (List.map
        (fun farbe -> List.concat [
          xzgroup ("dungeon"^farbe) (fill_anim ("md"^farbe) (""::ziele) "");
	  sequenz farbe 4 "" render4;
	  sequenz farbe 3 "-UV" render3;
	  sequenz farbe 2 "" render2;
	  List.concat (List.map (pov_fill ("md"^farbe) "Version") render);
	])
        farben);
      ml_prog "mdGold" ["helfer"];
      [["mdGold.inc"],
        ["mdGold"],
        ["./mdGold > mdGold.inc"]];
      [["cuyo.ppm"],
        ["cuyo.xpm";"machppm"],
        ["./machppm cuyo"]];
      (* Die Augen des Egos kommen vom Augen-Level. *)
      stuff_of_prog ["mdAuge.ppm"]
        "gen_augen" (string_of_int(5*gric)^" mdAuge");

      (* Und seine Haare werden von povray erzeugt. *)
      [["mdEgoHaare.data"; "mdEgoHaare.ppm"],
        ["mdEgoHaare.pov"; "mdEgo.inc";
          "dungeon.inc"; "dungeon_boden.inc"; "cuyopov.inc"],
        ["povray +FP -D -w1 -h1 mdEgoHaare.pov"]];

      (* Um sich die Prägung auf den Goldmünzen anzusehen: *)
      xpm_of_pov 10 5 "mdGoldM" (includes "Gold");
      pov_fill2 "mdGold" "mdGold" "Version" "-1" "M";

      (* Um sich die verschiedenen Bodenpflanzen anzusehen: *)
      xpm_of_pov_fill 5 5 "mdBodenP" (includes "Boden")
        "BodenPflanze" (num_anim 1 1 5);
      pov_fill2 "mdBoden" "mdBoden" "BodenVersion" "-1" "P";

      (* Um sich die Blätter der Bäume anzusehen: *)
      xpm_of_pov 15 15 "mdHolzB" (includes "Holz");
      pov_fill2 "mdHolz" "mdHolz" "Version" "-1" "B";

    ]);


    group_of_ml "fische"
      ("mfmuschel" :: "mfqualle" :: (fill_anim "mffisch" (num_anim 1 1 6) ""))
      ml_vektorgraphik;


    group_of_ml "flechtwerk"
      ["mflAlles";"mflGrasV";"mflKlein"]
      ml_vektorgraphik;


    group "fractals" ["aDragon.xpm.gz"];
    [["aDragon.xpm.gz"], ["aDragon.ps"],
      ["convert aDragon.ps aDragon.xpm.gz"]];


    xzgroup "jump" (fill_anim "mjZeug" (num_anim 1 1 6) "");
    recolour "mjZeug.src" "mjZeug1" (Some (255,0,0));
    recolour "mjZeug.src" "mjZeug2" (Some (255,255,0));
    recolour "mjZeug.src" "mjZeug3" (Some (0,255,0));
    recolour "mjZeug.src" "mjZeug4" (Some (0,0,255));
    recolour "mjZeug.src" "mjZeug5" (Some (255,0,255));
    recolour "mjZeug.src" "mjZeug6" (Some (255,255,255));


    group_of_ml "kacheln" ["mkaSechseckRahmen"; "mkaSechseckKacheln";
        "mkaViereckRahmen"; "mkaViereckKacheln"; "mkaViereckFall";
        "mkaFuenfeckRahmen"; "mkaFuenfeckKacheln"; "mkaFuenfeckFall";
	"mkaFuenfeckHetz";
        "mkaRhombusKacheln"; "mkaRhombusFall"; "mkaRhombusLeer"]
      ml_vektorgraphik;


    xzgroup "kolben" ["mkKolben"; "mkKolbenBlitzBlau";
      "mkKolbenBlitzGruen"; "mkKolbenBlitzRot"];
    recolour "mkKolben.src" "mkKolben" None;
    recolour "mkKolben.src" "mkKolbenBlitzBlau" (Some (0,0,255));
    recolour "mkKolben.src" "mkKolbenBlitzGruen" (Some (0,255,0));
    recolour "mkKolben.src" "mkKolbenBlitzRot" (Some (255,0,0));


    xzgroup "novips" (fill_anim "mnv" (num_anim 1 1 6) "");
    recolour "mnv.src" "mnv1" (Some (255,0,0));
    recolour "mnv.src" "mnv2" (Some (255,255,0));
    recolour "mnv.src" "mnv3" (Some (0,255,0));
    recolour "mnv.src" "mnv4" (Some (0,255,255));
    recolour "mnv.src" "mnv5" (Some (0,0,255));
    recolour "mnv.src" "mnv6" (Some (255,0,255));


    group_of_ml "octopi"
      ("moAnemone"::"moFisch"
        ::(fill_anim "moOctopus" (num_anim 1 1 5) ""))
      ml_vektorgraphik;


    group_of_ml "puzzle" ["mpAlle"] ml_vektorgraphik;


    xzgroup "rechnen" (fill_anim "mreZahl" (num_anim 1 1 3) "");
    recolour "mreBasis" "mreZahl1" (Some (0,0,0));
    recolour "mreBasis" "mreZahl2" (Some (255,0,0));
    recolour "mreBasis" "mreZahl3" (Some (0,0,255));


    xzgroup "reversi_brl" ["lreAlle"];
    xpm_of_pov 3 6 ~trans_colour:(Some (255,255,255)) "lreAlle" [];


    group_of_ml "rollenspiel" ["mrpAlle"] ml_vektorgraphik;


    group_of_ml "schemen" ["mscHinter"; "mscLeer"; "mscVerbind"]
      ml_vektorgraphik;


    group_of_ml "secret" ["mseKind"; "mseGG"]
      ml_vektorgraphik;


    (* slime *)
    (let slime_anim = num_anim 1 0 5  in
    let slime_pics = "msGreen"::"msRed"::(fill_anim "msRed" slime_anim "")  in
    List.concat [
      xzgroup "slime" slime_pics;
      List.concat (List.map
        (fun file -> xpm_of_pov_trans 5 1 file [])
        slime_pics);
      pov_fill2 "slime2" "msGreen" "Case" "1" "";
      pov_fill2 "slime2" "msRed" "Case" "2" "";
      List.concat (List.map
        (fun stage -> pov_fill "msRed" "Time" stage)
        slime_anim);
    ]);


    group_of_ml "tennis"
      (fill_anim "mt"
        ("Racket"::"Source"::"Wall"::
          (fill_anim "Roof" (num_anim 1 1 4) "") @
          (combine_anim ["Blue";"Green";"Grey";"Yellow"]
            ["Bounce";"Left";"Out";"Right"]))
        "")
      ml_vektorgraphik;


    xzgroup "trees" (fill_anim "mtr" (num_anim 1 1 5) "");
    recolour "mtr.src" "mtr1" (Some (255,128,0));
    recolour "mtr.src" "mtr2" (Some (0,192,0));
    recolour "mtr.src" "mtr3" (Some (0,0,255));
    recolour "mtr.src" "mtr4" (Some (128,0,255));
    recolour "mtr.src" "mtr5" (Some (128,128,128));


    xzgroup "xcf" [
      "i3Dreieck"; "i3Gitter"; "i3Grau"; "i3Kreis"; "i3Plus"; "i3Quadrat";
      "i3Stern";
      "ipStart";
      "itrBlau"; "itrBraun"; "itrGrau"; "itrGruen"; "itrLila";
      "iwaBad"; "iwaBeton"; "iwaNix"; "iwaParkett"; "iwaTeppich";
      "lrKamin"; "lrWasser"];
    xpms_of_xcf "i3Bunt" [
      "i3Dreieck",[0;3];
      "i3Gitter",[0;1];
      "i3Kreis",[0;5];
      "i3Plus",[0;2];
      "i3Quadrat",[0;6];
      "i3Stern",[0;4];
      ];
    xpm_of_xcf [0;1;2;3] "i3Grau";
    xpm_of_xcf [0] "ipStart";
    xpms_of_xcf "itrAlle" [
      "itrBlau",[0;4];
      "itrBraun",[2;4];
      "itrGrau",[4];
      "itrGruen",[3;4];
      "itrLila",[1;4];
      ];
    xpms_of_xcf "iwaAlles" [
      "iwaBad",[0;4;5;12];
      "iwaBeton",[0;6;12];
      "iwaNix",[0;6;7];
      "iwaParkett",[0;3;5;12];
      "iwaTeppich",[0;1;2;12];
      ];
    xpm_of_xcf [1;2;3] "lrKamin";
    xpm_of_xcf [0;1] "lrWasser";


    xzgroup "zahn" ["mzZahn"; "mzZahnGras"; "mzZahnDreh"];
    xpm_of_pov_trans 3 9 "mzZahn" ["zahn.inc"];
    xpm_of_pov_trans 3 9 "mzZahnGras" ["zahn.inc"];
    xpm_of_pov_trans 4 8 "mzZahnDreh" ["zahn.inc"];
    pov_fill2 "mzZahn" "mzZahn" "Gras" "1" "Gras";


    xzgroup "ziehlen" ["mziAlle"];
    xpm_of_pov_trans 5 2 "mziAlle" [];


    ml_module "gen_common" ["easyarg"];
    ml_module "helfer" [];
    ml_module "pam" [];
    ml_module "natmod" [];
    ml_module "vektor" ["natmod"];
    ml_module "farbe" ["natmod"; "vektor"];
    ml_module "xpmlex" ["farbe"];
    ml_module "graphik" ["pam"; "farbe"; "xpmlex"; "helfer"];
    ml_module "polynome" ["helfer"];
    ml_module "vektorgraphik" ["helfer"; "farbe"; "graphik"; "polynome"];
    ml_module "easyarg" [];
    [["xpmlex.ml"],
      ["xpmlex.mll"],
      ["ocamllex xpmlex.mll"]];
    ml_prog "machxpm" ("easyarg"::ml_graphik);
    ml_prog "machppm" ("easyarg"::ml_graphik);

  ]

(*===========================================================================*)

;;

main rules ();

