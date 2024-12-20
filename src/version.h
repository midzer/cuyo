/***************************************************************************
                        version.h  -  description
                             -------------------
    begin                : Sat Mar 25 2006
    copyright            : (C) 2006 by Mark Weyer
    email                : cuyo-devel@nongnu.org

Modified 2006,2008,2009,2011,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/


#ifndef VERSION_H
#define VERSION_H

#include "stringzeug.h"
#include <set>
#include <vector>
#include <map>



enum { /* Die nur-ausschließend-Dimensionen */
  dima_schwierig,
  anzahl_dima
};

enum { /* Die ausschöpfend- (und also auch ausschließend-) Dimensionen */
  dimaa_numspieler = anzahl_dima,
  dimaa_levelpack,
  anzahl_dim
};



struct Dimension {
  bool mInitialized;
  int mGroesse;
  std::vector<Str> mMerkmale;
  std::vector<Str> mProsaNamen;
  std::vector<Str> mErklaerungen;

  Dimension();
  void init(int,
	    const char * const * const,
	    const char * const * const,
	    const char * const * const);
  int suchMerkmal(const Str &);  /* Ersatzwert -1 */
};



class Version {
  friend class VersionMapIntern; /* eigentlich nur assertWohlgeformt() */

  std::set<Str> mMerkmale;

public:

  /** Leere Menge, also keine spezielle Version */
  Version();

  /** Spezialisiert die Version um ein Merkmal.
      Das darf aber nicht "" sein. */
  void nochEinMerkmal(const Str &);

  bool enthaelt(const Str & merkmal) const;
  bool speziellerAls(const Version &) const;

  bool operator < (const Version & v2) const;
  bool operator == (const Version & v2) const;
  bool operator != (const Version & v2) const;

  Str toString() const;

  /* Liefert die Ausprägung der Dimension dimension,
     oder def, wenn es keine gibt.
     Prüft nach, daß es höchstens ein solches Merkmal gibt.
     Das Merkmal wird dabei gelöscht.
     Bei mehreren Ausprägungen gibt es eine exception vom Typ Str,
     die nicht besonders aussagekräftig ist: Sie enthält nur diese
     Merkmale als string. Sie ist dazu da, gecatcht und mit einer
     Erklärung versehen in einen Fehler oder iFehler verwandelt zu werden. */
  Str extractMerkmal(int dim, const Str & def);
  int extractMerkmal(const Dimension & dim, int def);


  /** Ab hier Objektmodul:
      ====================
      (Das heißt, ab jetzt ist alles static und die Klasse Version daher
      nicht mehr als ein namespace Version.)
  */

  /** Among other things, this sets the informational texts, so it should
      be called after init_NLS(). */
  static void init();

  /** Liefert zu einer Dimension die zulässigen Merkmale.
      Das sind immer ausschließend-Dimensionen. Ob es auch ausschöpfend-
      Dimensionen sind, braucht den Aufrufer nicht zu interessieren,
      spiegelt sich aber darin wider, daß der leere String fehlt. */
  static const std::set<Str> auspraegungen(int dim);

  static Dimension gLevelpack;
  static Dimension gSchwierig;

  /** Beeinflussen die Wohlgeformtheitsüberprüfung.

      Eine (Merkmal-)Menge ist legal, wenn sie aus keiner Menge aus
      gAusschliessend und gAusschoepfend mehr als ein Element enthält.
      Sie ist superlegal, wenn sie weiterhin aus jeder Menge aus
      gAusschoepfend genau ein Element enthält.

      Superlegale Merkmalmengen entsprechen Versionen, in denen das
      Spiel existieren kann. Versionen in Wertangaben dürfen auch
      unterspezifiziert sein und ihre Merkmalmengen brauchen daher
      nur legal zu sein.

      Eine Versionenmenge ist wohlgeformt, wenn jede Version in ihr
      legal ist, und sie unter jeder superlegalen Version genau ein
      maximales Element aufweist. Ein vorhandener Default zählt für
      die allgemeinste Version, ohne selbst in der Menge vorzukommen. */
  static std::set<std::set<Str> > gAusschliessend;
  static std::set<std::set<Str> > gAusschoepfend;
};




class VersionMapIntern {

  /** In mGeprueft stehen die Schlüssel, deren Versionen schon auf
      Wohlgeformtheit geprüft wurden. Sobald das passiert ist,
      werden keine weiteren Einträge mehr zugelassen (und es wird
      nicht nochmals geprüft). Daher ist Bestapproximierende auch
      nicht const.
      Die, die die Prüfung auch bestanden haben, stehen dann in mGut.

      Da diese Stempel vergeben werden von Funktionen, die eigentlich
      nur Daten auslesen, hab ich die Auslesefunktionen als "const"
      deklariert und dafuer diese Stempelvariablen als "mutable"
      */
  mutable std::set<Str> mGeprueft;
  mutable std::set<Str> mGut;
  std::map<Str, std::map<Version,void*> > mVerzeichnis;

public:

  /** Der Index läuft über alle Daten, also alle Versionen aller Schlüssel.
      Der constIndex natürlich auch. */

  class IndexIntern {
    friend class VersionMapIntern;

    std::map<Str, std::map<Version,void*> > *         eigner;
    std::map<Str, std::map<Version,void*> >::iterator intern1;
    std::map<Version,void*>::iterator                      intern2;

  public:
    IndexIntern(VersionMapIntern &);

    inline bool ende() const {return intern1==eigner->end();}
    void operator++ ();
    const Str & schluessel() const;    /** Vorbedingung: !ende() */
  protected:
    void* datumIntern() const;        /** Vorbedingung: !ende() */
  };


  class constIndexIntern {
    friend class VersionMapIntern;

    const std::map<Str, std::map<Version,void*> > *         eigner;
    std::map<Str, std::map<Version,void*> >::const_iterator intern1;
    std::map<Version,void*>::const_iterator                      intern2;

  public:
    constIndexIntern(const VersionMapIntern &);

    inline bool ende() const {return intern1==eigner->end();}
    void operator++ ();
    const Str & schluessel() const;    /** Vorbedingung: !ende() */
    const Version & version() const;        /** Vorbedingung: !ende() */
  protected:
    const void* datumIntern() const;        /** Vorbedingung: !ende() */
  };


  friend class VersionMapIntern::IndexIntern;
  friend class VersionMapIntern::constIndexIntern;


  VersionMapIntern();

  /** Löscht den Eintrag.
      Es gibt keine leeren Versionsmengen: Ist es die letzte Version
      seines Schlüssels, wird der Schlüssel ganz vergessen. */
  void loescheEintrag(IndexIntern &);

  bool enthaelt(const Str &) const;
  bool enthaelt(const Str &, const Version &) const;

protected:

  void neuerEintragIntern(const Str & schluessel, const Version & version,
			  void* inhalt);

  /** Liefert unter den Einträgen, die zu schluessel existieren, den,
      dessen Version die größte Teilmenge von version ist.
      Bei defaultVorhanden wird vielleicht ein Nullzeiger zurückgegeben.
      Ruft assertWohlgeformt auf. */
  void* BestapproximierendeIntern(const Str & schluessel,
				  const Version & version,
				  bool defaultVorhanden) const;

private:

  bool geprueft(const Str & schluessel) const;

  /** Testet, ob Bestapproximierende eindeutig sind.
      falls nicht defaultVorhanden wird auch auf Existenz geprüft.
      Bei nicht bestandenem Test gibts einen Fehler. */
  void assertWohlgeformt(const Str & schluessel, bool defaultVorhanden) const;

};



template <class Datum>
class VersionMap : public VersionMapIntern {

public:

  class Index : public IndexIntern {
  public:
    inline Index(VersionMap & m) : IndexIntern(m) {}
    inline Datum* datum() const {return (Datum*) datumIntern();}
  };

  class constIndex : public constIndexIntern {
  public:
    inline constIndex(const VersionMap & m) : constIndexIntern(m) {}
    inline const Datum* datum() const {return (Datum*) datumIntern();}
  };

  inline void neuerEintrag(const Str & schluessel,const Version & version,
			   Datum* inhalt) {
    neuerEintragIntern(schluessel, version, (void*) inhalt);
  }

  /** Liefert unter den Einträgen, die zu schluessel existieren, den,
      dessen Version die größte Teilmenge von version ist.
      Bei defaultVorhanden wird vielleicht ein Nullzeiger zurückgegeben.
      Ruft assertWohlgeformt auf. */
  inline Datum* Bestapproximierende(const Str & schluessel,
				    const Version & version,
				    bool defaultVorhanden) const {
    return (Datum*) BestapproximierendeIntern(schluessel,version,
					      defaultVorhanden);
  }
};



#endif

