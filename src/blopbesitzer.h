/***************************************************************************
                          blopbesitzer.h  -  description
                             -------------------
    begin                : Sat Jul 14 2001
    copyright            : (C) 2001 by Immi
    email                : cuyo@karimmi.de

Modified 2001-2003,2005,2006,2008,2010,2011 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef BLOPBESITZER_H
#define BLOPBESITZER_H


/* Rückgabewerte von getVerbindungen(). Achtung: Wenn diese Konstanten
   geändert werden, muss auch Sorte::malMitVerbindungen geändert werden */
#define verbindung_rechts 0x0004
#define verbindung_links  0x0040
#define verbindung_unten  0x0010
#define verbindung_oben   0x0001
#define verbindung_lu	  0x0020
#define verbindung_lo	  0x0080
#define verbindung_ru     0x0008
#define verbindung_ro     0x0002
#define verbindung_solo   0x0100
#define verbindung_alle4  0x0055 // wird von Go-Steinen benutzt






class Blop;
class Spielfeld;

/**Klasse, die Blops "besitzt" und von ihrem Besitztum
erfahren möchte, wenn es sich verändert.
  *@author Immi
  */

class BlopBesitzer {
public:
  BlopBesitzer(Spielfeld * spf);
  virtual ~BlopBesitzer() {}
  /** Da BlopGitter der einzige BlopBesitzer ist, der diese Methode
      überschreiben möchte (naja, fast), kann sie auch gleich daran
      angepasst sein... */
  virtual int getBesitzVerbindungen(int /*x*/, int /*y*/) const {
    return verbindung_solo;
  }
  /** For Blopgitters, this returns the Blop at the specified coordinates.
      May not be called otherwise, or with incorrect coordinates.
      This is used for accessing variables at foreign coordinates. */
  virtual const Blop & getFeld(int /*x*/, int /*y*/) const;
  /** Dito. */
  virtual Blop & getFeld(int x, int y);
  /** Liefert true, wenn die angegebenen Koordinaten "im BlopBesitzer"
      liegen. Genauer: Liefert true, wenn getFeld() mit diesen
      Koordinaten aufgerufen werden darf. */
  virtual bool koordOK(int /*x*/, int /*y*/) const {
    return false;
  }
  virtual const Blop * getFall(int a) const;
  virtual Blop * getFall(int a);
  virtual int getSpezConst(int /*vnr*/, const Blop *) const;

protected:
  Spielfeld * mSpf;
};

#endif
