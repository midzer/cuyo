/***************************************************************************
                          global.h  -  description
                             -------------------
    begin                : Mit Jul 12 22:54:51 MEST 2000
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

#ifndef GLOBAL_H
#define GLOBAL_H

class Str;


/* In dieser Datei werden all die Dinge definiert, von denen ich nicht
   weiß, wo ich sie hin tun soll. Unter anderem ein paar globale Variablen. */


/** True, wenn -d übergeben wurde, d. h. im Debug-Modus. */
extern bool gDebug;

/** Pfad, wo das Cuyo-Programm liegt, das aufgerufen wurde (aus
    argv[0] extrahiert. Wird vom PfadIterator gebraucht, um nach
    Leveln zu suchen. */
extern Str gCuyoPfad;

/** True, wenn der Benutzer den Namen einer ld-Datei übergeben hat. */
extern bool gDateiUebergeben;

/** Wenn eine ld-Datei übergeben wurde, dann ist das der Name davon. */
extern Str gLevelDatei;





/** Entfernt von p alles, was nach dem ersten Punkt kommt. Ist dazu da
    um aus einem "bla.xpm", was unter pics steht, den Namen für Programme
    zu extrahieren. */
Str picsEndungWeg(const Str & p);


/** d sollte ein Pfad mit Dateiname sein. Liefert nur den Pfad-Anteil
    zurück (d. h. alles vor dem letzten "/". Liefert "./", falls d keinen
    "/" enthält. */
Str nimmPfad(Str d);


/** d sollte ein Pfad mit Dateiname sein. Liefert nur den nicht-Pfad-Anteil
    zurück (d. h. alles nach dem letzten "/". Liefert alles, falls d keinen
    "/" enthält. */
Str vergissPfad(Str d);




#endif
