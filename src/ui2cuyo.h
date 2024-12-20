/***************************************************************************
                          ui2cuyo.h  -  Lists all routines of cuyo which
			  the ui calls.
                             -------------------
    begin                : Mit Jul 12 22:54:51 MEST 2000
    copyright            : (C) 2006 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2006,2008,2010,2011,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef UI2CUYO_H
#define UI2CUYO_H

#include <vector>

#include "version.h"
#include "stringzeug.h"

namespace Cuyo {

  /* Hier sind die public-Methoden von Cuyo, die das ui aufrufen darf. */



  /** "construtor"
      PrefsDaten::init() must be called first. */
  void init();
  /** "destructor" */
  void destroy();
  

  /** Ein key-Event halt... (Kümmert sich um alle Tasten,
      die während des Spiels so gedrückt werden...). */
  void keyEvent(const SDL_keysym & taste);
  
  /** Eine Taste wurde gedrueckt, von der das ui befunden hat, dass
      es sich um eine debug-Taste handeln koennte.
      Liefert zurueck, ob die Taste tatsächlich erkannt werden konnte. */
  bool debugKeyEvent(const SDL_keysym & taste);

  /** Die Haupt-Zeitschritt-Routine. Wird direkt
      vom ui aufgerufen. Ruft alle spielschritt()-Routinen u.ä. auf. */
  void zeitSchritt();

  /** Markiert alle Graphik auf upzudaten; danach muss noch malSpielfeld()
      aufgerufen werden, um das Update wirklich zu machen */
  void setUpdateAlles();
  
  /** Spielfeld neu malen. Wird vom ui aufgerufen. */
  void malSpielfeld(int sp);

  /** NaechstesFall neu malen. Wird vom ui aufgerufen. */
  void malNaechstesFall(int sp);

  /** Startet das Spiel für die eingestellte Spielerzahl und mit dem
      angegebenen Level */
  void startSpiel(int level);

  //#define spielermodus_1_spieler 1
  //#define spielermodus_2_spieler 2
  #define spielermodus_computer 3

  int getSpielerZahl();
  int getSpielerModus();
  /** Setzt #Spieler, KI-Modus; gemerkte Level-Nummer wird auf 0
      zurueckgesetzt. Vorbedingung: Es läuft grad kein Spiel. */
  void setSpielerModus(int spm);

  Version berechneVersion();

  /** Der int ist der Index in Version::mLevelpack bzw Version::mSchwierig */
  void setLevelpack(int);
  int getLevelpack();
  void setSchwierig(int);
  int getSchwierig();

  /* Liefert Nr. des zuletzt gespielten Levels (oder 0) */
  int getLetzterLevel();



  /** Womöglich in der falschen Datei: Hier wird reingespeichert,
      welche Version (zuletzt) auf der Kommandozeile stand.
      Achtung! Das passiert schon vor Cuyo::init(), also vor der
      Lebenszeit von Cuyo, wenn Cuyo eine hätte. */
  extern Version mKommandoZeilenVersion;

}

#endif
