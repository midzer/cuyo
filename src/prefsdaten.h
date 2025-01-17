/***************************************************************************
                          prefsdaten.h  -  description
                             -------------------
    begin                : Fri Jul 21 2000
    copyright            : (C) 2000 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2003,2006,2010,2011,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef PREFSDATEN_H
#define PREFSDATEN_H

#include <set>
#include <vector>

#include "SDL2/SDL.h"

/* Konstanten f�r das Tasten-Array */
/* Achtung: Vor �ndern dieser Konstanten checken, ob
   ui::zeigePrefs() immernoch so von diesen Konstanten abhaengt. */
#define taste_anz 4
#define taste_links 0
#define taste_rechts 1
#define taste_dreh 2
#define taste_fall 3



/** Datenstruktur f�r das, was in .cuyo steht:
    Das, was man im preferences-Dialog und im Hauptmenue einstellen kann und
    welche Level gewonnen wurden. */

namespace PrefsDaten {

  /** Requires Version::init() to have been run. */
  void init();

  /** Returns true if level lnr has already been won. */
  bool getLevelGewonnen(bool sp2, int lnr);


  /** sp2: true bei zweispielermodus.
      Requires Version::init() to have been run. */
  void schreibGewonnenenLevel(bool sp2, const Str intlena);
  
  /** Liefert true, wenn die Taste k belegt ist, und speichert dann
      in sp und t ab, was die Taste tut. */
  bool getTaste(SDL_Keycode k, int & sp, int & t);
  
  SDL_Keycode getTaste(int sp, int t);
  double getKIGeschwLin();
  int getKIGeschwLog();
  
  void setTaste(int sp, int t, SDL_Keycode code);
  void setKIGeschwLog(int kigl);

  bool getSound();
  void setSound(bool s);

  int getPlayers();
  void setPlayers(int);

  int getLevelTrack();
  void setLevelTrack(int);

  int getDifficulty();
  void setDifficulty(int);

  Str getLastLevel();
  void setLastLevel(const Str);

  /** Sollte nach Aenderungen mit set...() aufgerufen werden.
      Requires Version::init() to have been run. */
  void schreibPreferences();
}


#endif
