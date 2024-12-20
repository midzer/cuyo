/***************************************************************************
                          sound.h  -  description
                             -------------------
    begin                : Fri Jul 21 2000
    copyright            : (C) 2000 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2003,2004,2006,2011 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef SOUND_H
#define SOUND_H


class Str;

/* Wichtig: include inkompatibel.h muss _vor_ dem nachfolgenden stehen. */
#ifdef CUYO_SOUND
#include <mikmod.h>
#endif

/* Namen der Sample-Dateien stehen in sound.cpp */
#define sample_nix (-1)
#define sample_links 0
#define sample_rechts 0
#define sample_dreh 1
#define sample_fall 2
#define sample_land 3
#define sample_explodier 4
#define sample_menuclick 5
#define sample_menuscroll 6
#define sample_levelwin 7
#define sample_levelloose 8

#define fix_sample_anz 9

#define spieler_niemand 2

enum SoundOrt {
  so_fenster,
  so_lfeld,  /* auch bei Einzelspieler */
  so_rfeld,
  so_lsemi,
  so_rsemi,
  so_global
};

namespace Sound {

  void init();
  void destroy();
  
  /** Sollte aufgerufen werden, wenn sich Pref->sound
      möglicherweise geändert hat */
  void checkePrefsStatus();
  

  /** Spielt die angegebene Mod-Datei immer wieder ab.
      Bei na = "" wird nix abgespielt. */
  void setMusic(Str na);
  
  /** Lädt den angegebenen Sample und liefert eine Nummer zurück,
      mit dem man ihn abspielen kann. */
  int ladSample(Str na);
  
  /** Gibt alle Samples wieder frei, die mit ladSample geladen worden
      sind, außer die, die init() geladen hat. Sollte nach Levelende
      aufgerufen werden, wenn die Levelsounds nicht mehr gebraucht werden.
      (Aber erst, wenn die ld-Dateien einzeln geladen werden.) */
  void loescheUserSamples();
  
  /** Spielt das Sample mit der angegebenen Nummer (die entweder eine
      der obigen Konstanten ist oder von ladSample zurückgeliefert wurde).
      so,xz,xn bestimmen die x-Position für Stereo-Effekte.
      Dabei ist xz/xn ein Bruch, 0 für den linken und 1 für den rechten
      Rand von so. Bei so=so_global werden xz und xn ignoriert. */
  void playSample(int nr, SoundOrt so, int xz=1, int xn=2);
  
}

#endif
