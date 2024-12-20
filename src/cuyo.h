/***************************************************************************
                          cuyo.h  -  description
                             -------------------
    begin                : Mit Jul 12 22:54:51 MEST 2000
    copyright            : (C) 2000 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2001-2003,2006,2008,2010,2011,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef CUYO_H
#define CUYO_H

#include "stringzeug.h"
#include "version.h"
#include "spielfeld.h"

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif



#include "leveldaten.h" // wegen grx, gry, max_spielerzahl; sollte woanders hin

class Fehler;





class KIPlayer;
class Spielfeld;

/** Cuyo -- Das Fenster.

    Ein paar allgemeine Definitionen:
    
    Blop: eins von diesen Kügelchen. Auch Graue oder Gras, etc.
    
    Version (eines Blops): Untersorte (ursprünglich vom Gras)
    
    Zustand eines Blops: 1. Wo in der Animation befindet es sich?
    2. Welche Version ist es?
    
    Standardblop: Kügelchen, aber kein Graues, etc.
    
    Farbe: eine Sorte von Standardblops.
    
    Bilddatei: Ein Pixmap so wie es geladen wurde.
    
    Bildchen: ein 32x32-Pixmap(-Ausschnitt).
    
    Schema: System, nach dem die Blob-Bildchen mit Anschlüssen aus den xpms
    erzeugt werden
 */

namespace Cuyo {

  /* ***
     Weitere public-Methoden befinden sich in ui2cuyo.h
     *** */

  
  /** liefert true, wenn das Spiel normal läuft, false
      wenn das Spiel am zuende gehen ist. (Liefert während Pause
      auch true) */
  bool getSpielLaeuft();
  /** liefert true, wenn das Spiel gepaust ist. */
  bool getSpielPause();
  /** Liefert die Anzahl der Mitspieler zurück. */
  int getSpielerZahl();
  
  /** Liefert das Pause-Bildchen zurück */
  Bilddatei * getPauseBild();
  
  /** Liefert true, wenn debug-Rüberreihen-Test aktiv ist */
  bool getRueberReihenTest();

  /** Liefert ein Spielfeld zurück. */
  Spielfeld * getSpielfeld(bool reSp);

		
  /**  */
  void neuePunkte(bool reSp, int pt);
  /** wird aufgerufen, wenn ein Spieler tot ist */
  void spielerTot();
  
  /* reSp sendet g Graue an den anderen Spieler */
  void sendeGraue(bool reSp, int g);
  
  /** reSp bittet den anderen Spieler um eine Reihe. Er selbst
      hat Höhe h. Antwort ist eine der Konstanten bewege_reihe_xxx */
  int bitteUmReihe(bool reSp, int h);

  /** reSp will einen Stein vom anderen Spieler (rüberreihe) */
  void willStein(bool reSp, Blop & s);
}




#endif

