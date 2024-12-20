/***************************************************************************
                          configdatei.h  -  description
                             -------------------
    begin                : Sun Jul 1 2001
    copyright            : (C) 2001 by Immi
    email                : cuyo@karimmi.de

Modified 2001,2002,2006,2011 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef CONFIGDATEI_H
#define CONFIGDATEI_H


#include <set>

#include "stringzeug.h"

#include "sdltools.h"

#include "inkompatibel.h"


/**Parst die .cuyo-Datei. (level descr wird von DatenDatei geparst.)
  *@author Immi
  */

class ConfigDatei {
 public:
  ConfigDatei(const Str & name);
  ~ConfigDatei();
  /** Liefert den aktuellen Abschnitt */
  Str getAbschnitt() const;
  /** Wechselt zum angegebenen Abschnitt. (Abschnitte werden durch
      [bla] eingeleitet.) Liefert false, wenn der Abschnitt nicht existiert. */
  bool setAbschnitt(Str na = "");
  /** Liefert den Eintrag, wenn er existiert, sonst den default-String
      (der per default "" ist). */
 protected:
  /** Liefert true, wenn der Eintrag existiert; schreibt ihn ggf. nach ret */
  bool getEintragIntern(const Str & schluessel, Str & ret) const;
 public:
  Str getEintrag(const Str & schluessel,
		       Str def = "") const;
  /** Gibt's den Eintrag? */
  bool hatEintrag(const Str & schluessel) const;
  /** Liefert den Eintrag als Zahl, wenn er existiert, sonst die
      default-Zahl. */
  int getZahlEintrag(const Str & schluessel, int def = 0) const;
//   /** Liefert den Eintrag als Farbe, wenn er existiert, sonst die
//       default-Farbe. */
//   Color getFarbEintrag(const Str & schluessel,
// 		       const Color & def = Color(0, 0, 0)) const;
  /** Liefert einen Eintrag als Komma-getrennte Liste
      ohne Beachtung der Reihenfolge */
  int getMengenEintrag(const Str & schluessel,
		       std::set<Str> & menge) const;

 protected:
  Str mName;
  /** 0, wenn sich die Datei nicht öffnen ließ */
  FILE * mDatei;
	
  Str mAbschnitt;
  int mAbschnittPos;

	
  /** Liefert zurück, was für ein Zeilentyp die Zeile ist:
      leer, abschnitt, zuweisung. In a und b werden interessante
      Positionen abgespeichert... */
  int getZeilenTyp(const Str & z, int & a, int & b) const;
  /** Wenn ein Parse-Fehler in Zeile z aufgetreten ist... */
  void fehlerZeile(const Str & z) const;
};



/** Ändert den Abschnitt zeitweilig (so lange, bis das Objekt wieder
		zerstört wird.) */
class ConfigAbschnittPush {
 public:
  ConfigAbschnittPush(ConfigDatei & c, const Str & name): mConf(c) {
    mMerk = mConf.getAbschnitt();
    mKlappt = mConf.setAbschnitt(name);
  }
  ~ConfigAbschnittPush() {
    if (mKlappt) mConf.setAbschnitt(mMerk);
  }
  bool hatGeklappt() {
    return mKlappt;
  }
 protected:
  ConfigDatei & mConf;
  Str mMerk;
  bool mKlappt;
};




#endif
