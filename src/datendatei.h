/***************************************************************************
                          datendatei.h  -  description
                             -------------------
    begin                : Sun Jul 1 2001
    copyright            : (C) 2001 by Immi
    email                : cuyo@karimmi.de

Modified 2002,2005,2006,2010,2011 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef DATENDATEI_H
#define DATENDATEI_H

#include "inkompatibel.h"
#include "knoten.h"
#include "sdltools.h"

class Code;
class VarDefinition;

/** Parst die level.descr Datei und alle Dateien, die davon included
    werden. Bietet danach Möglichkeiten, darauf zuzugreifen.
    
    Noch ein Hinweis: Auf dem geparsten Baum befindet sich ein
    Eichhörnchen (= Squirrel; ist schneller zu tippen), dass sich um
    das Auslesen der Daten kümmert. Es liest natürlich die Daten von
    dort, wo es sich befindet. (Und es gibt Methoden, die ihm sagen,
    wo es hingehen soll.)
    
    (Oje, ist die Wurzel des Baums jetzt oben oder unten?)

    Ausführliche Beschreibung des Parse-Vorgangs siehe leveldaten.h.
    
    Nicht zu verwechseln mit ConfigDatei, was die alte Version von
    level.descr geparst hat und jetzt nur noch für die .cuyo-Datei
    verwendet wird.
    @author Immi
  */


class DatenDateiPush;


class DatenDatei {
 friend class DatenDateiPush;
 
 public:
  DatenDatei();
  ~DatenDatei();

  /** Entfernt alles, was bisher geladen wurde. Aufrufen, wenn man alles
      neu laden möchte. */
  void leeren();  

  /** Lädt die angegebene Datei. (Kann mehrmals aufgerufen werden, um
      mehrere Dateien gleichzeitig zu laden.) */
  void laden(const Str & name);


  /***** Squirrel-Methoden *****/
  
  /** Setzt das Squirrel an die Wurzel des Baums. */
  void initSquirrel();
  
  /** Liefert true, wenn das Squirrel sich an einer Stelle des Baums
      befindet, die existiert. */
  bool existiertSquirrelKnoten() const;
  
  /** Liefert die Position des Squirrels als String. */
  Str getSquirrelPosString() const;
  
  /** Liefert die Squirrel-Position zurück (und zwar
      mSquirrelCodeKnoten; siehe dort). */
  DefKnoten * getSquirrelPos() const;


protected:
  /** Das Eichhörnchen klettert weiter weg von der Wurzel. Wird von
      DatenDateiPush benutzt. */
  void kletterWeiter(const Str & na, const Version & version);
  
public:



  /***** Eintrag-Methoden *****/
  
  /** Liefert den Eintrag, wenn er existiert, sonst null, wenn
      defaultVorhanden, sonst wird gethrowt. */
  const DatenKnoten * getEintrag(const Str & schluessel,
				 const Version & version,
				 bool defaultVorhanden,
				 int typ = type_EgalDatum) const;
  /** Dito für Wörter. Default für def ist "". */
  Str getWortEintragOhneDefault(const Str & schluessel,
			  const Version & version) const;
  Str getWortEintragMitDefault(const Str & schluessel,
				    const Version & version,
				    Str def = Str()) const;
  
  /** Gibt's den Eintrag? */
  bool hatEintrag(const Str & schluessel) const;
  /** Liefert den Eintrag als Zahl. */
  int getZahlEintragOhneDefault(const Str & schluessel,
				const Version & version) const;
  int getZahlEintragMitDefault(const Str & schluessel,
			       const Version & version, int def = 0) const;
  /** Wie getZahlEintrag, aber akzeptiert nur 0 und 1. */
  bool getBoolEintragOhneDefault(const Str & schluessel,
				 const Version & version) const;
  bool getBoolEintragMitDefault(const Str & schluessel,
				const Version & version, bool def) const;
  /** Liefert den Eintrag als Farbe. */
  Color getFarbEintragOhneDefault(const Str & schluessel,
				   const Version & version) const;
  Color getFarbEintragMitDefault(const Str & schluessel,
				  const Version & version,
				  const Color & def = Color(0, 0, 0)) const;
  /** Liefert einen Eintrag als Knoten.
      Bei defaultvorhanden kann das Ergebnis 0 sein. */
  ListenKnoten * getListenEintrag(const Str & schluessel,
				  const Version & version,
				  bool defaultVorhanden) const;

  /** Sucht einen Code beim Squirrel oder näher an der Wurzel.
      Behält den Besitz am Code/an der VarDefinition.
      Throwt bei nicht-existenz. */
  Code * getCode(const Str & name, const Version & version,
		 bool defaultVorhanden);
  VarDefinition * getVarDef(const Str & name, const Version & version,
		 bool defaultVorhanden);




 protected:
 
   /** Der oberste Knoten der (geparsten) Datei */
   DefKnoten * mDaten;
  
  /* Ort des Eichhörnchens als String. */
  Str mSquirrelPosString;
  /* Der Knoten, an dem sich das Squirrel befindet. Ist 0, wenn es sich
     an einem Knoten befindet, den es gar nicht gibt. */
  DefKnoten * mSquirrelKnoten;
  /* Eigentlich auch der Knoten des Squirrels. Wenn
     der allerdings nicht existiert, dann der letzte Knoten,
     der noch existiert hat. Dort wird nach Code gesucht. */
  DefKnoten * mSquirrelCodeKnoten;


  /** Liefert den angegebenen Eintrag beim Squirrel.
      Prüft, ob der Typ der gewünschte ist.
      Liefert 0, wenn's den Eintrag nicht gibt, aber defaultVorhanden.
      Throwt bei sonstigem Fehler. */
  Knoten * getEintragKnoten(const Str & schluessel,
			    const Version & version,
			    bool defaultVorhanden, int typ) const;

};




/***************************************************************************/



/** Ist dazu da, um bei einer Datendatei das Squirrel klettern zu lassen.
    Gebrauchsanweisung:
    {
      DatenDateiPush ddp(dat, "Unterabschnitt");
      if (!hatGeklappt)
        throw Fehler("Abschnitt existiert nicht");
      ...
    } // Hier automatisch Ende vom Push
    */
class DatenDateiPush {
 public:
  DatenDateiPush(DatenDatei & c,
		 const Str & name,const Version & version,
                 bool verlange = true);
		 
  ~DatenDateiPush();
  
 protected:
  DatenDatei & mConf;
  Str mMerkName;
  DefKnoten * mMerkKnoten;
  DefKnoten * mMerkCodeKnoten;
};




#endif
