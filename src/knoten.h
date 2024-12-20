/***************************************************************************
                          knoten.h  -  description
                             -------------------
    begin                : Sun Jul 1 2001
    copyright            : (C) 2001 by Immi
    email                : cuyo@karimmi.de

Modified 2002,2005,2006,2008,2009,2011 by the cuyo developers
Maintenance modifications 2012 by Bernhard R. Link
Maintenance modifications 2012 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef KNOTEN_H
#define KNOTEN_H

#include <vector>
#include <map>

#include "version.h"

#include "fehler.h"


#define type_egal 0  // wird von DatenDatei::getEintragKnoten() benutzt
#define type_DefKnoten 1
#define type_ListenKnoten 2
#define type_DatenKnoten 3

#define type_EgalDatum 0  // wirft keinen Fehler beim Typecheck
#define type_WortDatum 1
#define type_ZahlDatum 2
#define type_VielfachheitDatum 3

#define namespace_prozedur 0
#define namespace_variable 1


/* Die Tiefen der DefKnoten. */
#define tiefe_global 0
#define tiefe_level 1
#define tiefe_sorte 2


/* Die Rollen von Argumenten */
#define zahlrolle_einzige 0
#define wortrolle_einziges 0


class Code;
class DatenKnoten;
class Definition;




/***********************************************************************/
/* Knoten */


/** Wenn die Level.descr geparst wird, wird das Ergebnis als ein
    Baum von Knoten gespeichert. Für den Baum gilt (im Moment) folgendes:
    - Die Wurzel ist ein DefKnoten.
    - Kinder von DefKnoten sind DefKnoten oder ListenKnoten.
    - Kinder von ListenKnoten sind DatenKnoten.
*/
class Knoten {


  /** Datei, in der dieser Knoten definiert wurde (für Fehlermeldungen) */
  Str mDateiName;
  /** Zeilen-Nr, in der dieser Knoten definiert wurde (für Fehlermeldungen) */
  int mZeilenNr;

public:
  Knoten(Str datna, int znr): mDateiName(datna), mZeilenNr(znr) {}
  
  virtual ~Knoten() {}
  
  virtual int type() const = 0;
  
  virtual Str toString() const = 0;

  /** Liefert einen String zurück, der angibt, wo dieser Code
      definiert wurde (für Fehlermeldungen) */
  Str getDefString() const;
};






/***********************************************************************/
/* DefKnoten */



//typedef std::map<Str, Knoten *> tKnotenMap;

typedef VersionMap<Knoten> tKnotenMap;
typedef VersionMap<Definition> tCodeSpeicher;



/** Knoten der Form
    bla=...
    blub=...
    <<
    bild=...
    gras=...
    >>
    Das was rechts von bla und blub steht, sind Kinder:
    Entweder DefKnoten oder ListenKnoten.
    Das, was in <<...>> steht, ist Code. (Neu: Code ist auch Knoten.)
*/
class DefKnoten: public Knoten {

  /** Die Knoten-Kinder dieses Knotens */
  tKnotenMap mKinder;
  
  /** Die Code-"Kinder" dieses Knotens */
  tCodeSpeicher mCodeSpeicher[2];
  
  /** Wenn man von hier aus im Baum nach oben läuft der nächste
      DefKnoten, den man trifft. (Wird benötigt, um auf den
      CodeSpeicher vom Vater zuzufreifen.) */
  DefKnoten * mVater;
  
  /** 0 bei der Wurzel, 1 bei Kindern der Wurzel (Level-DefKnoten), etc. */
  int mTiefe;
  
  /** Nur für den Top-Knoten: 1, wenn schon eine Level-Defintion
      gespeichert ist. Wenn danach noch Cual-Code kommt, wird eine Warnung
      ausgeben.
      3, wenn die Warnung schon ausgegeben wurde. */
  int mErstLevelDannCual;


  /** Variablen werden intern durchnummeriert. Hier steht die
      nächste freie Nummer (bzw. die Anzahl der belegten Nummern).
      
      Bei Sorten-Defknoten sind diese Variablen nicht von Bedeutung;
      um die Nummerierung der Sorten-Variablen kümmert sich auch der
      Level-DefKnoten. So hat intern jede Sorte alle Variablen.
      (Die Variablen-Definitionen stehen allerdings trotzdem im
      Code-Speicher der Sorten, so dass die Sortenvariablen-Namespace
      getrennt ist.
      
      Überblick über die ganzen Spezial-Variablen-Nummern siehe
      definition.h, bei class VarDefinition. */
  int mVarNrBei;
  /** Nummer der nächsten freien Bool-Variable. -1, wenn's grad
      keine freien Bool-Variablen gibt. */
  int mBoolNrBei;
  
  /** Die Default-Werte der Variablen, nochmal nach Nummer aufgelistet.
      Wird von den Blops benötigt, wenn die Variablen am Anfang
      initialisiert werden. Allerdings nur Default-Werte von echten
      Variablen (d. h. von Variablen, die Speicher belegen.) */
  std::vector<int> mDefaultWerte;
  std::vector<int> mDefaultArten;

  /** Wenn dieser Knoten VarDefinitionen für Sortennamen verwalten soll,
      muß er sich merken, für welche Sortenliste er bei welcher Nummer
      angefangen hat. Das ist mit den jeweiligen bloparten indiziert. */
  std::map<Str,int> mSortenAnfaenge;


  
public:
  
  /** Erzeugt den Top-Knoten. */
  DefKnoten();
  
  /** Erzeugt einen Unter-Knoten. */
  DefKnoten(Str datna, int znr, DefKnoten * vater);
  
  virtual ~DefKnoten();
  
  virtual int type() const {return type_DefKnoten;}

  virtual Str toString() const;
  
  void fuegeEin(const Str & na, const Version & version, Knoten * wert);
  
  /** Löscht alle Kinder raus, die DefKnoten sind und nicht
      "Title" heißen.
      Wird von LevelDaten::ladLevelSummary() gebraucht. */
  void loeschAlleLevel();
  
  bool enthaelt(Str na) {return mKinder.enthaelt(na);}
  
  Knoten * getKind(const Str & na, const Version & version,
		   bool defaultVorhanden) {
    return mKinder.Bestapproximierende(na,version,defaultVorhanden);
  }
  
  
  /***** Methoden für den Codespeicher *****/


  /** Speichert alle vordefinierten Variablen in den
      Namespace, außer die pics-Konstanten. Wird vom Constructor
      des WurzelKnotens aufgerufen. */
  void speicherGlobaleVordefinierte();

  /** Speichert die Pics-Konstanten. (picsliste sollte der pics-Knoten sein.)
      Wird von fuegeEin(...) aufgerufen, wenn es die pics bekommt.
      Alternativ auch bei greypic und startpic.
      Welches davon steht in schluessel */
  void speicherPicsConst(const Version & version, Knoten * picsliste,
			 const char* schluessel);

  /** Speichert eine Konstante mit dem Namen, der in nameKnoten steht und
      dem angegebenen Wert. nameKnoten ist hoffentlich ein ListenKnoten
      mit genau einem Eintrag. Wird von fuegeEin() aufgerufen, um die
      Gras-, die Grau- und die nix-Konstante abzuspeichern, wenn es die
      bekommt. */
  void speicherKnotenConst(const Version & version, Knoten * nameKnoten,
			   int wert);

  
  /* Erzeugt eine neue Var-Definition und speichert sie ab. Dabei
     bekommt sie auch gleich eine Nummer. (Aufzurufen, wenn eine
     VarDefinition geparst wurde.) def ist der Default-Wert. */  
  void neueVarDefinition(const Str & na, const Version& version,
                         int def, int defart);

  /* Speichert eine neue Definition - Code oder Variable. Noch unschön:
     Sollte von außen nur für Code aufgerufen werden. Bei Variablen immer
     neueVarDefinition verwenden! */
  void speicherDefinition(int ns, const Str & na, const Version & version,
			  Definition * f);
  
  /** Liefert eine Code-Definition aus diesem Speicher oder von
      weiter oben. Throwt bei nichtexistenz.
      Achtung: Behält den Besitz an der Defintion. */
  Definition * getDefinition(int ns, const Str & na,
			     const Version & version, bool defaultVorhanden);

  /** Liefert ein Kind von hier oder von weiter oben. */
  Knoten * getVerwandten(const Str & na, const Version & version,
			 bool defaultVorhanden);


  
  /***** Variablen-Nummern-Verwaltung *****/


  
  /** Erzeugt eine unbenannte Variable und liefert die Nummer zurück.
      def wird als default-Wert in mDefaultWerte gespeichert. */
  int neueVariable(int def, int defart);

  void neuerDefault(int var, int def, int defart);

  /** Erzeugt eine unbenannte Bool-Variable und liefert
      die Nummer zurück. */
  int neueBoolVariable();
  
  
  /** Liefert zurück, wie viel Speicher für Variablen jeder Blop
      reservieren muss. Nur auf Level-Ebene aufrufen. */
  int getDatenLaenge() const;
  
  /** Liefert den Default-Wert der Variable mit Nummer nr. Es
      muss aber eine richtige Variable sein, die echten Blop-
      Speicherplatz verbraucht. (Sonst soll man sich den Default-
      Wert aus der VarDefinition holen. Das hier ist nur für
      Variablen-Anfangs-Initialisierung.) */
  int getDefaultWert(int nr) const;
  int getDefaultArt(int nr) const;
  

  /** Liest mSortenAnfaenge aus. Throwt bei Nichtexistenz.
      Nimmt den entsprechenden ld-Eintrag wie "pics" als Index. */
  int getSortenAnfang(const Str &) const;
  
  /** Liefert zurueck, wie viele Sortennummern insgesamt schon
      von mSortenAnfaenge belegt sind. */
  int getSortenAnzahl() const;

};



/***********************************************************************/
/* ListenKnoten */


typedef std::vector<Knoten *> tKnotenListe;


/** Knoten der Form bla1, bla2, bla3. Kinder sind DatenKnoten. */
class ListenKnoten: public Knoten {

  tKnotenListe mKinder;

public:

  ListenKnoten(Str datna, int znr);
  ~ListenKnoten();
  
  virtual int type() const {return type_ListenKnoten;}

  virtual Str toString() const;

  void fuegeEin(Knoten * wert) {
    mKinder.push_back(wert);
  }
  

  int getVielfachheit(int nr) const;
  
  int getLaenge() const {
    return mKinder.size();
  }

  /** Dies rechnet Vielfachheiten mit ein */
  int getImpliziteLaenge() const;

  /** Dies auch, geht aber nur bis zum physischen Index nr.
      Somit gilt:

          getKernDatum(i) == getImplizitesDatum(getLaengeBis(i))
  */
  int getLaengeBis(int nr) const;

  
  Knoten * getKind(int nr) {
    return mKinder[nr];
  }

  const DatenKnoten * getDatum(int nr, int solltyp = type_EgalDatum);

  /** Dies wirft Vielfachheiten bei der Ausgabe weg */
  const DatenKnoten * getKernDatum(int nr, int solltyp = type_EgalDatum);

  /** Dies rechnet Vielfachheiten beim Index mit ein */
  const DatenKnoten * getImplizitesDatum(int nr, int solltyp = type_EgalDatum);


  /** Setzt voraus, daß es nur einen Eintrag gibt. Gibt diesen Eintrag. */
  const DatenKnoten * getEinzigesDatum(int solltyp = type_EgalDatum);
};




/***********************************************************************/
/* DatenKnoten */


/** Enthält echte Daten und nicht bloß weitere Knoten */
class DatenKnoten: public Knoten {

public:

  DatenKnoten(Str datna, int znr): Knoten(datna, znr) {}

  virtual int type() const {return type_DatenKnoten;}

  virtual int datatype() const = 0;

  /** liefert sich selbst zurück, damit man keinen namespace verschwendet */
  const DatenKnoten * assert_datatype(int) const;

  virtual int getZahl(int /* rolle */ = zahlrolle_einzige) const {
    CASSERT(false);}

  virtual Str getWort(int /* rolle */ = wortrolle_einziges) const {
    CASSERT(false);}

};




/***********************************************************************/
/* WortKnoten */


/** Ein Wort-Knoten. "bla" oder bla. */
class WortKnoten: public DatenKnoten {
  Str mWort;
  
public:

  WortKnoten(Str datna, int znr, Str w):
    DatenKnoten(datna, znr), mWort(w) {}

  virtual int datatype() const {return type_WortDatum;}

  virtual Str getWort(int rolle = wortrolle_einziges) const;

  virtual Str toString() const;
  
};




/***********************************************************************/
/* ZahlKnoten */


/** Enthält eine Zahl */
class ZahlKnoten: public DatenKnoten {
  int mZahl;

public:

  ZahlKnoten(Str datna, int znr, int z):
    DatenKnoten(datna, znr), mZahl(z) {}

  virtual int datatype() const {return type_ZahlDatum;}

  virtual int getZahl(int rolle = zahlrolle_einzige) const;

  virtual Str toString() const;
  
};


/***********************************************************************/
/* VielfachheitKnoten */


/** Enthält ein Wort und eine Vielfachheit des Wortes. */
class VielfachheitKnoten: public DatenKnoten {
  Str mWort;
  int mZahl;
  WortKnoten mNurDasWort;

public:

  VielfachheitKnoten(Str datna, int znr, Str w, int z):
    DatenKnoten(datna, znr), mWort(w), mZahl(z), mNurDasWort(datna,znr,w) {}

  virtual int datatype() const {return type_VielfachheitDatum;}

  virtual int getZahl(int rolle = zahlrolle_einzige) const;

  virtual Str getWort(int rolle = wortrolle_einziges) const;

  virtual const WortKnoten * getNurDasWort() const {return & mNurDasWort;}

  virtual Str toString() const;
  
};




#endif

