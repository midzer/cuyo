/***************************************************************************
                          pfaditerator.h  -  description
                             -------------------
    begin                : Thu Jul 26 2001
    copyright            : (C) 2001 by Immi
    email                : cuyo@karimmi.de

Modified 2001,2002,2004,2006,2008,2011 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef PFADITERATOR_H
#define PFADITERATOR_H

#include "stringzeug.h"




/** Iteriert durch alle Pfade, an denen sich eine
    Daten-Datei befinden könnte. Throwt selbständig, wenn
    die Datei gar nicht existiert.
    Wenn der übergebene Dateiname schon ein absoluter Pfad ist,
    wird nicht iteriert.
    Bei auch_gz = true ist die Fehlerausgabe etwas anders.
    Bei setzDefault = true wird der Pfad, in dem die Datei gefunden
    wurde, als default-Pfad gespeichert, d. h. als der Pfad, in dem
    später als erstes gesucht wird. Passiert hauptsächlich (nur?)
    beim Parsen der Haupt-Level-Datei main.ld oder einer übergebenen
    ld-Datei.
Verwendung:
  for (PfadIterator pi("pics/miez.xpm"); !test_ex(pi.pfad()); ++pi);

  *@author Immi
  */

class PfadIterator {
public: 
  PfadIterator(Str dat, bool auch_gz = false, bool setzDefault = false);
  ~PfadIterator();
  
  /** Nächster Pfad */
  PfadIterator & operator++();
  
  /** Aktueller Pfad */
  Str pfad() const;

 protected:
  int mPos;
  Str mDatei;
  /** true: In Zukunft soll der Default-Pfad der sein, wo diese Datei
      gefunden wird. */
  bool mSetzDefault;
  /** true, wenn wir (was nicht von PfadIterator verwaltet wird, sondern
      von ladXPM), alternativ auch nach .gz suchen. Das hat nur Einfluß auf
      die Fehlermeldung von ++(). */
  bool mAuch_gz;
  /** true, wenn von vornerein ein absoluter Pfad angegeben wurde.
      (Dann wird nicht durch verschiedene Pfade iteriert.) */
  bool mIstAbsolut;

  /** Nummer vom Default-Pfad */
  static int gDefaultPfad;

  /** Der wesentliche Teil von ++(), aber ohne Fehlertest */
  void plusplusIntern();
  
 public:
  /** Vergisst, welcher Pfad als default gesetzt wurde */
  static void loescheDefault();
};

#endif
