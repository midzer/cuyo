/***************************************************************************
                          punktefeld.h  -  description
                             -------------------
    begin                : Wed Jul 12 2000
    copyright            : (C) 2000 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2002,2006,2008,2010,2011 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef PUNKTEFELD_H
#define PUNKTEFELD_H

#include <SDL.h>

#include "bilddatei.h"

/** Zeigt die Punkte eines Spielers hübsch an. Achtung: Erst _nach_
    ld-Datei-Laden erzeugen. (Weil erst dann die nötigen Bildchen
    geladen werden.) */
class Punktefeld {
public:
  Punktefeld();


  void setPunkte(int p);

  void zwinkerSchritt();

  /* Malt, falls noetig, die Punkte neu */
  void updateGraphik(bool force = false);
  

private:
  int mPunkte;
  int mAugenZu;
  /** Der normale Zufallsgenerator darf (im Moment) nicht verwendet werden,
      weil sonst das log-Zeugs durcheinander kommt. Schade eigentlich. Dann
      machen wir uns halt unseren eigenen. */
  static unsigned int gRandSeed;
  /** True, wenn sich was geändert hat, d. h. wenn der Bildschirminhalt
      nicht aktuell ist */
  bool mUpdateNoetig;


  static Bilddatei * gZiffernBild[2];

public:
  static void init();
  static void destroy();
};


#endif
