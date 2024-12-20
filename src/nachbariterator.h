/***************************************************************************
                          nachbariterator.h  -  description
                             -------------------
    begin                : Thu Jul 26 2001
    copyright            : (C) 2001 by Immi
    email                : cuyo@karimmi.de

Modified 2001,2002,2005,2006,2011,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef NACHBARITERATOR_H
#define NACHBARITERATOR_H

/**Iteriert durch alle Nachbarn eines Punktes.
(Nachbarn im Sinne von Kette zählt als verbunden.)
Verwendung:
  for (NachbarIterator i(x, y); i; ++i) {
    bla(i.mX, i.mY);
  }
  *@author Immi
  */

class Sorte;

class NachbarIterator {
public: 
  NachbarIterator(const Sorte * s, bool rechts, int x, int y);
  ~NachbarIterator();

  /** Nächster Nachbar */
  NachbarIterator & operator++();
  
  operator bool() {
    return !mEnde;
  }
  
protected:

  int mNachbarschaft;
  bool mRechts;
  int mX0, mY0;
  int mI;
  bool mEnde;
  
  void setXY();
  
public:
  /** Zum auslesen: die (absoluten) Koord. vom Nachbarn */
  int mX, mY;
  /** Zum auslesen: die Nachbar-Richtung und die entgegengesetzte
      Richtung. Konstanten dazu stehen in sorte.h */
  int mDir, mDirOpp;
};

#endif
