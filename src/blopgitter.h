/***************************************************************************
                          blopgitter.h  -  description
                             -------------------
    begin                : Thu Jul 12 2001
    copyright            : (C) 2001 by Immi
    email                : cuyo@karimmi.de

Modified 2001-2003,2005,2006,2008,2010,2011,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef BLOPGITTER_H
#define BLOPGITTER_H

#include "blop.h"
#include "blopbesitzer.h"
#include "layout.h"


class Spielfeld;


/**Array, in dem die (festen) Blops eines Spielfelds gespeichert werden.
  *@author Immi
  */

class BlopGitter: public BlopBesitzer {
 public:
  /** re: true bei rechtem Spieler */
  BlopGitter(bool re, Spielfeld * spf);
  ~BlopGitter();

  /** Löscht alles */
  void init();

  /** Liefert true, wenn was am platzen ist */
  bool getWasAmPlatzen() const;

  /** Animiert alle Blops. Innerhalb einer Gleichzeit aufrufen. Danach
      stehen in mNeuePunkte() evtl. Punkte, die der Spieler bekommen
      soll. */
  void animiere();
		
  /** Liefert ein Feldinhalt zurück */
  const Blop & getFeld(int x, int y) const;

  /** Liefert ein Feldinhalt zurück */
  Blop & getFeld(int x, int y);

  /** liefert true, wenn der Blob bei x, y sich mit b verbinden kann. */
  bool getFeldVerbindbar(int x, int y, const Blop & b) const;
	
  /** liefert die Feldart bei x, y; (d. h. grau oder gras oder leer
      oder normaler Stein oder außerhalb vom Spielfeld). */
  int getFeldArt(int x, int y) const;

  /** Testet das Verhalten des Blobs bei x,y. Liefert false, wenn es den
      Blob gar nicht gibt. */
  bool getFeldVerhalten(int x, int y, int verhalten) const;

  /** verschiebt einen Blop (auch wenn er explodiert oder
      sonstwie grad animiert ist).  */
  //void verschiebBlop(int x1, int y1, int x2, int y2);

  /** liefert eine VerbindungsBitliste für den Blop bei x, y. */
  int getBesitzVerbindungen(int x, int y) const;
  /** liefert true, wenn (x,y) im Spielfeld liegt */
  bool koordOK(int x, int y) const;
  /** liefert true, wenn an die Stelle (x,y) gemalt werden
  *  kann: entweder, es liegt im Spielfeld, oder es ist
  *  einer der Hexmodus-Rand-Blops.
  *  Im Moment testen wir gar nicht, ob wir im Hexmodus
  *  sind (und wenn ja, in einer geeigneten Spalte). Das
  *  heißt, dass ein bisschen Zeit verschwendet wird, wenn
  *  Cual-Code an eine der gar nicht sichtbaren Stellen
  *  malt.
  */
  bool koordMalOK(int x, int y) const;
  /** Setzt, ob die Rüberreihe existiert. */
  void setRueberReihe(bool ex);
  /** Liefert die Anzahl der Zeilen zurück, d. h. normalerweise
      gry; aber wenn die Rübergebreihe existiert, dann eins mehr. */
  int getGrY() const;
  /** Liefert true, wenn man mal wieder testen sollte, ob was
      platzt. Achtung: Das Flag wird bei diesem Aufruf gleich
      gelöscht. */
  bool getTestPlatz();
  /** Liefert true, wenn (x, y) leer ist und das erste nichtleere darüber
      schwebend ist. Wird von Fall benötigt. */
  bool testPlatzSpalte(int x, int y);
  
  /** Sendet an alle Blops das connect-Event. */
  void sendeConnectEvent();

  virtual int getSpezConst(int vnr, const Blop *) const;

 protected:

  /** _die_ Spielfelddaten. Letzte Zeile für die Rüberreihe. */
  Blop mDaten[grx][gry + 1];
  /** Extra-Zeile nur-Bildstapel-Blops, für den unteren Bereich
      im Hex-Modus. (Nur jeder zweite dieser Blops wird verwendet.) */
  Blop mHexExtra[grx];

  /** True, wenn mal wieder getestet werden sollte, ob was platzt. */
  //bool mTestPlatz;
	
  /** Existiert die Rüberreihe? */
  bool mRueberReihe;

  /** Punkte, die während der Animationen angefallen sind */
  //int mNeuePunkte;
};

#endif
