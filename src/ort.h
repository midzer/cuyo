/***************************************************************************
                          ort.h  -  description
                             -------------------
    begin                : Sat Nov 26 2005
    copyright            : (C) 2005 by Mark Weyer
    email                : cuyo-devel@nongnu.org

Modified 2005,2006,2011,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/


#ifndef ORT_H
#define ORT_H

#include "definition.h"

class Blop;
class Code;
class DefKnoten;



enum AbsOrtArt {
  absort_feld,
  absort_fall,
  absort_semiglobal,
  absort_global,
  absort_info,
  /* absort_bemalbar ist ein dummy-Wert für reine Bildstapelblops.
   * Der Ort des Blops wird nicht wirklich angegeben (er wird auch
   * nicht benötigt), aber malen kann man trotzdem dort hin */
  absort_bemalbar,
  absort_nirgends
};


struct ort_absolut {
  AbsOrtArt art;
  bool rechts; /** bei absort_global und absort_nirgends irrelevant */
  int x;       /** nur bei absort_feld und absort_fall relevant.
                   bei absort_fall zaehlt es mod 2 */
  int y;       /** nur bei absort_feld und absort_fall relevant.
  		   With absort_fall it determines which fall is meant:
                   0 for the current fall.
                   1 for the fall preview.
                   2 for the fall preview preview, if we ever do that.
                   and so on. */

  ort_absolut(AbsOrtArt aart, bool arechts = false, int ax = 0, int ay = 0) :
    art(aart), rechts(arechts), x(ax), y(ay) {}

  /** Darf finde() benutzt werden? Normalerweise werden
      Orte von reine Bildstapelblops als inkorrekt angesehen.
      mit willNurMalen = true kann das geändert werden. */
  bool korrekt(bool willNurMalen = false);

  Blop & finde();

  /** Hat der Ort einen Platz auf dem Bildschirm? */
  bool bemalbar();

  Str toString() const;
  void playSample(int nr) const;  /* Kann mit absort_fall nicht umgehen. */
};



enum OrtArt {
  ortart_hier, ortart_relativ_feld, ortart_relativ_fall, ortart_absolut
};

enum OrtHaelfte {
  haelfte_hier, haelfte_drueben, haelfte_links, haelfte_rechts
};




class Ort: public Definition {

  /** Siehe Konstanten ortart_... */
  OrtArt mArt;

  AbsOrtArt mAbsArt;     /** nur relevant bei ortart_absolut */
  OrtHaelfte mHaelfte;   /** irrelevant bei ortart_hier oder absort_global */

  Code * mXKoord;
  Code * mYKoord;

public:

  /** ortart_hier */
  Ort();

  /** ortart_relativ_fall */
  Ort(Code * x);

  /** ortart_relativ_feld */
  Ort(Code * x, Code * y);

  /** ortart_absolut */
  Ort(AbsOrtArt absart, Code * x = 0, Code * y = 0);

  Ort(DefKnoten * knoten, const Ort & f, bool neueBusyNummern);

  ~Ort();

  bool hier();

  void setzeHaelfte(OrtHaelfte haelfte);

  ort_absolut berechne(ort_absolut vonhieraus, Blop & fuer_code);

  Str toString() const;
};



#endif

