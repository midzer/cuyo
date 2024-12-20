/***************************************************************************
                          xpmladen.h  -  description
                             -------------------
    begin                : Mon May 28 2001
    copyright            : (C) 2001 by Immi
    email                : cuyo@karimmi.de

Modified 2002,2006,2008,2011 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
 
 
#ifndef XPMLADEN_H
#define XPMLADEN_H


#include <SDL.h>

#include "maske.h"

class Str;


/* Versucht die Datei na zu laden.
   Versucht auﬂerdem, die Datei na.gz zu laden.
   Liefert 0, wenn keine der Dateien existiert.
   Throwt, wenn's beim Laden einen Fehler gibt.
   (Falls die SDL-Lad-Routine verwendet wird, kann nicht versucht werden,
   die .gz-Datei zu laden.)
   Die Spezialfarbe "Background" definiert unter anderem die Maske. */
SDL_Surface * ladXPM(Str na, RohMaske &);

#endif
