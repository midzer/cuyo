/***************************************************************************
                          layout.h  -  description
                             -------------------
    begin                : Mit Jul 12 22:54:51 MEST 2000
    copyright            : (C) 2006 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2008,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef LAYOUT_h
#define LAYOUT_h


/* I decided to put the window size defines in some central include file
   where sdltools could find them. Then I noticed that I also need grx,
   gry and gric in that file. And then I noticed that these three are
   needed by many many other files. So now layout.h is included by many
   files, so that it might be a good idea to either
   (a) remove everything from this file except
      grx, gry, gric and the window size things
      and move them back to blatt.h
   or
   (b) move grx, gry, gric and the window size into another file which
      anyway is included by almost everything.
   Option (b) has the advantage that e.g. punktefeld.cpp does not
   need to include blatt.h just because it needs layout information.
*/




/* Größe des Levels */
#define grx 10
#define gry 20

#define gric 32 // Größe der Bildchen


// Defined in font.h:
//#define L_font_width 24  // (Abstand der Buchstaben in der Font-Grafik)
//#define L_font_height 24

/*** Defines für Fenster-Layout ***/
/* Höhe der Punkteanzeige */
#define L_punkte_hoehe 32
/* Rand zwischen den verschiedenen Objekten */
#define L_rand 8

#define L_spielfeld_breite (grx * gric)
#define L_spielfeld_hoehe (gry * gric)

#define L_fenster_hoehe L_spielfeld_hoehe
#define L_fenster_breite_2sp (4 * L_fenster_hoehe / 3)

#define L_wunsch_hoehe (L_fenster_hoehe + 2 * L_rand)
#define L_wunsch_breite (L_fenster_breite_2sp + 2 * L_rand)

#define L_spieler_breite ((L_fenster_breite_2sp - L_rand) / 2)

#define L_infos_breite (L_spieler_breite - L_spielfeld_breite - L_rand)
#define L_infos_hoehe (L_spielfeld_hoehe)

#define L_fenster_breite_1sp L_spieler_breite


/* Durch Komma getrennte Liste:
   1-spieler, 2-spieler:erster-spieler, 2-spieler:zweiter-spieler */
#define L_spielfeld_x \
      (L_infos_breite + L_rand),\
      (L_infos_breite + L_rand), \
      ((L_fenster_breite_2sp + L_rand) / 2)
#define L_spielfeld_y 0

#define L_infos_x \
      0,\
      0, \
      (L_fenster_breite_2sp - L_infos_breite)

#define L_naechstesfall_hoehe (gric)
#define L_player_y (4 * gric)
#define L_punkte_y (8 * gric)
#define L_infoblobsep (gric/4)
#define L_levelexplode_dy (gric/4)

#define L_greygrass_x1 0
#define L_greygrass_x2 (gric + L_rand)
#define L_levelexplode_x1 0
#define L_levelexplode_x2 (gric + L_rand)

#define L_naechstesfall_x (L_infos_breite / 2 - gric)
#define L_chainreactioninfo_y (L_infos_hoehe - gric)
#define L_levelexplode_y (L_chainreactioninfo_y - L_levelexplode_dy)
#define L_connectioninfo_y (L_levelexplode_y - L_levelexplode_dy)
#define L_grass_y (L_connectioninfo_y - L_infoblobsep - gric)
#define L_grey_y (L_grass_y - L_infoblobsep - gric)
#define L_infoblobs_y (L_grey_y)
#define L_infoblobs_breite (gric)
#define L_infoblobs_hoehe (L_chainreactioninfo_y + gric - L_grey_y)



/* Ab hier: Layout von Menüs und so */

/* Brauchen die Menüs die ganze 4/3-mal-Fensterhöhe als Breite?
   Ich denke nicht; dann können wir an den Seiten etwas weniger Platz
   beanspruchen und so bei anderen Fensterformen die Menüs
   etwas größer darstellen.
   
   Falls die Menüs doch gerne breiter würden, dann einfach diese
   Konstante wieder ändern (aber nicht auf mehr als
   L_fenster_breite_2sp.)
*/
#define L_fenster_breite_menus L_fenster_hoehe


#define L_menueintrag_defaulthoehe 32
#define L_menueintrag_highlight_rad 16 /* Änderungen auch nach
					  some_pic_sources/highlight.pov
					  propagieren */
/* Um wie viele Pixel soll der Hintergrund größer sein als die Schrift? */
#define L_menu_rand_lr 8
#define L_menu_rand_ou 4

#define L_AI_pfeil_sep_li 0  // Abstand Name - Pfeil ...
#define L_AI_pfeil_sep_re 32  // Nicht: Abstand Zahl - Pfeil

#define L_menu_scroll_freiraum (L_menu_hoehe/4)
#define L_menu_scroll_vorsprung (L_menu_hoehe/6)
#define L_bigskip L_menueintrag_defaulthoehe
#define L_medskip (L_bigskip/3)
#define L_hotkeysep 16
#define L_grausep 16
#define L_auswahlsep 16
#define L_datensep 16
#define L_infosep 16  // Abstand Info-Zeile - Unterer Fensterrand
#define L_info_hspace (L_fenster_breite_menus/3)
#define L_info_scrollspeed (L_fenster_breite_menus/80)

#define L_info_hoehe (L_infosep + L_font_height)
#define L_menu_hoehe (L_fenster_hoehe - L_info_hoehe)

#define L_auswahlmenu_pfeilsep 60  // Abstand zur Mitte
#define L_auswahlmenu_anim_dx 20
#define L_auswahlmenu_anim_schritte 3

#define L_scroll_beschleunigung 25 // in Pixeln pro Zeitschritt^2
#define L_maus_scroll_geschwindigkeit 50

#define L_scrollleiste_buttonzahl 5
#define L_scrollleiste_x (L_fenster_breite_menus - 2 * gric)
#define L_scrollleiste_y ((L_menu_hoehe - L_scrollleiste_buttonzahl * gric) / 2)



/* SDLTools uses english constants */

#define L_usual_height L_fenster_hoehe
#define L_usual_width L_fenster_breite_2sp

#define L_preferred_height L_wunsch_hoehe
#define L_preferred_width L_wunsch_breite



#endif
