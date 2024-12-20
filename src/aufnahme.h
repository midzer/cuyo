/***************************************************************************
                          record.h  -  description
                             -------------------
    begin                : Thu Jul 20 2000
    copyright            : (C) 2000 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2002,2006,2011 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/


#ifndef RECORD_H
#define RECORD_H

class Str;




class Spielfeld;

/***** Diese Funktionen dienen dazu, Spiele aufzunehmen und abzuspielen.
       *****/

/** Irgend wann wird das vielleicht mal eine Klasse namens Aufnahme.
    Bis dahin mach ich's mit einem Namespace. */
namespace Aufnahme {


/** Am Anfang eines Levels aufrufen.
    Allerdings erst *nach* ladLevel(), weil der
    Levelname schon zur Verfügung stehen muss.
    spz gibt die Anzahl der Spieler an (bzw. = spielermodus_computer falls gegen KI). */
void init(bool abspielen, int spz);


/** Liefert eine Zufallszahl... evtl. eine aufgenommene. (Im Moment bemerkt
    man die Tatsache, dass es sich um eine aufgenommene Zufallszahl handelt,
    gar nicht, weil das über das randseed geht.) */
int rnd(int bis);

/** Nimmt ggf. den Tastendruck t von Spieler sp auf.
    Muss bei jedem Tastendruck aufgerufen werden. */
void recTaste(int sp, int t);

/** Muss einmal vor jedem Spielschritt aufgerufen werden. Spielt ggf.
    Tastendrücke ab.
    spf muss das Haupt-Spielfeld-Array sein, damit Tastendrücke
    ausgeführt werden können. */
void recSchritt(Spielfeld ** spf);



void laden(Str pfad);

void speichern(Str pfad);


/** Liefert den Level-Namen zurück, für den die aktuelle Aufnahme ist. */
Str getLevelName();

/** Liefert die Spielerzahl zurück, für die die aktuelle Aufnahme ist. */
int getSpielerModus();


} // namespace Aufnahme


#endif
