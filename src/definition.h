/***************************************************************************
                          definition.h  -  description
                             -------------------
    begin                : Sun Jul 1 2001
    copyright            : (C) 2001 by Immi
    email                : cuyo@karimmi.de

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

#ifndef DEFINITION_H
#define DEFINITION_H

#include "stringzeug.h"






/** Diese Klasse hat als einzigen Zweck, gemeinsamer Vater von
    Code und VarDefinition zu sein. Das ist der Datentyp, den
    DefKnoten::speicherDefinition() und DefKnoten::getDefinition()
    nehmen.
*/
    
class Definition {
public:
  virtual ~Definition() {}
};



/***********************************************************************/
/* VarDefinition */


#define vd_variable 0
#define vd_spezvar 1
#define vd_spezconst 2
#define vd_konstante 3

/* Default-Arten. Sagen im wesentlichen aus, wann der Default genommen wird. */
enum {
  da_nie,        /* gar kein Default */
  da_keinblob,   /* nur für outside-Blobs */
  da_init,
  da_kind,       /* wenn kind geändert wird */
  da_event
};

/** Variablen-Definition. Nicht nur für benutzer-definierte
    Variablen gibt es eine Variablen-Definition, sondern auch für
    fast alle automatisch definierten Spezial-Dinge.


   Überblick über die ganzen Variablen- und Konstanten-Arten:

   Normale (benutzerdefinierte) Variablen:
     spezvar_anz <= mNummer

   Spezial-Variablen (automatisch definierte):
     0 <= mNummer < spezvar_anz

   Spezial-Konstanten (= nur-lese-Variablen):
     spezconst_anz <= mNummer < 0
     Belegt keinen Platz in Blop::mDaten.

   Normale Konstanten:
     Hat keine Nummer; schon beim Parsen wird jedes Auftreten
     der Variable durch den Wert ersetzt.
     Belegt keinen Platz in Blop::mDaten.

   Unsichtbare Variablen:
     Dafür gibt es keine VarDefinition. Hat aber auch eine Nummer
     und belegt Platz in Blop::mDaten.

*/

class VarDefinition: public Definition {
public:
  Str mName;
  int mDefault;
  int mArt;
  int mDefaultArt;
  int mNummer;
  
  //  VarDefinition(Str na, int d, int a = vd_variable, int n = 0);
  VarDefinition(Str na, int d, int a, int da, int n);

  int getDefault() const {return mDefault;}
  int getDefaultArt() const {return mDefaultArt;}
  
};




#endif
