/***************************************************************************
                          blop.h  -  description
                             -------------------
    begin                : Thu Jul 20 2000
    copyright            : (C) 2000 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2001-2003,2005,2006,2008,2010,2011,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef BLOP_H
#define BLOP_H

#include <vector>

#include <SDL.h>

#include "bildstapel.h"
#include "ort.h"

class Str;
class BlopBesitzer;
class Variable;
class VarDefinition;

/* blopart_... wird jetzt in sorte.h definiert... */

// liefert getFarbe manchmal zurück
#define keine_farbe (-1)

// Wert von mX und mY, falls das Blop nicht im Gitter ist
#define keine_koord 0x7fff

// Rückgabewert von getKonstante()
#define keine_konstante 0x7fff

/* Var-Nummern von speziellen Variablen */
#define spezvar_file 0
#define spezvar_pos 1
#define spezvar_kind 2
#define spezvar_version 3
#define spezvar_quarter 4
#define spezvar_out1 5
#define spezvar_out2 6
#define spezvar_kind_beim_letzten_draw_aufruf 7
#define spezvar_inhibit 8
#define spezvar_gewicht 9
#define spezvar_verhalten 10
#define spezvar_falling_speed 11
#define spezvar_falling_fast_speed 12
#define spezvar_am_platzen 13
#define spezvar_anz 14
/* spezvar_namen[] in knoten.cpp definiert. Es enthält auch
   die Namen der spezconst */

/* Var-Nummern von speziellen Konstanten */
#define spezconst_turn (-1)
#define spezconst_connect (-2)
#define spezconst_falling (-3)
#define spezconst_size (-4)
#define spezconst_loc_x (-5)
#define spezconst_loc_y (-6)
#define spezconst_loc_p (-7)
#define spezconst_players (-8)
#define spezconst_falling_fast (-9)
#define spezconst_exploding (-10)
#define spezconst_loc_xx (-11)
#define spezconst_loc_yy (-12)
#define spezconst_basekind (-13)
#define spezconst_time (-14)
#define spezconst_info (-15)
#define spezconst_anz 15


/* Return-Wert von BlopBesitzer::getSpezConst(), der besagt, dass der
   Default-Wert benutzt werden soll. Um das Einsetzen des Default-Werts
   kümmert sich Blop::getSpezConst() */
#define spezconst_defaultwert 0x7fff


#define bits_pro_int (8*sizeof(int))


/* Bit-Konstanten für spezvar_verhalten */
#define platzt_bei_gewicht 1
#define platzt_bei_platzen 2
#define platzt_bei_kettenreaktion 4
#define berechne_kettengroesse 8
#define verhindert_gewinnen 16
#define schwebt 32




/**Diese 32x32 Pixel großen Dinge heißen Blops.
   In diesem Objekt wird der Zustand eines Blops
   gespeichert (aber nicht seine Position). Es gibt auch
   den nicht-Blop.
   @author Immi
   */

class Blop {
 public:
  /** Erzeugt einen uninitialisierten Blop (der noch nicht verwendet
      werden kann, aber dafür auch keine Fehler hervorruft, wenn irgend
      was anderes nicht initialisiert ist). Das Uninitialisiert sein
      eines Blops erkennt man daran, dass mDaten 0 ist. */
  Blop();
  /** Constructor... s ist Sorte und v Version. v=-1 heißt Zufallsversion. */
  Blop(int s, int v=-1);
  /** Copy-Contructor... */
  Blop(const Blop & b);
  /** Destructor */
  ~Blop();
  /** Tut, was man erwartet. Tut *nicht* für reine Bildstapelblops. */
  Blop & operator=(const Blop & b);
  /** kopiert die Daten von b. Erwartet, dass die Datenlängen schon
      übereinstimmen. */
  void kopiere(const Blop & b);
  /** Verwandelt einen uninitialisierten Blop in einen Bildstapelblop;
   *  oder erzeugt den bildstapel neu (für Stapelhöhenänderungen bei
   *  Levelwechsel */
  void erzeugeBildstapel();

  /** Setzt Besitzer und Besitzer-Informationen. Braucht nur am Anfang einmal
      aufgerufen zu werden. Muss auch für den Global-Blop aufgerufen werden;
      sonst darf kein Code ausgeführt werden. */
  void setBesitzer(BlopBesitzer * bes = 0,
    ort_absolut ort = ort_absolut(absort_nirgends));


  /** Führt die ganzen Animationen durch (Codeanimationen und platzen).
      Sollte innerhalb einer Gleichzeit aufgerufen werden. */
  void animiere();
  
  /** Führt den Code des angegebenen Events aus (falls Code zu diesem
      Event existiert. Sollte innerhalb einer Gleichzeit aufgerufen
      werden.
      Die Event-Nummern sind in sorte.h definiert. */
  void execEvent(int evtnr);
  /** Wie execEvent; wird aber nicht sofort ausgeführt, sondern erst
      beim nächsten Aufruf von sendeGeschedulteEvents() */
  void scheduleEvent(int evtnr);
  /** Startet den Platzvorgang. Sollte nicht für leere Blops aufgerufen
      werden. */
  void lassPlatzen();

   
  /** Teilt einem Farbblop die (neue) Größe seiner Kette mit. */
  void setKettenGroesse(int anz);


  /** Liefert true, wenn der Blop sich seit dem letzten Aufruf von 	 
      takeUpdaten() verändert hat und deshalb neu gezeichnet werden muss.
      Liefert auf jeden Fall true, wenn der Blop zwischendrin kopiert wurde
      (mit = oder copy-Constructor). */ 	 
  bool takeUpdaten();


  /***** Funktionen, die nix verändern *****/

  /** malt den Blop, wobei xx und yy in Pixeln
      angegeben ist; der Hintergrund wird vorher
      gelöscht.
      If apply_mirror is set and the level is an upside-down one, then the
      respective coordinate-transformation is applied. */
  void malen(int xx, int yy, bool apply_mirror=true) const;
  /** liefert die Art zurück */
  int getArt() const;
  /** liefert die Farbe zurück, aber nur, wenns wirklich ein farbiges
      Blop ist (sonst wird keine_farbe zurückgeliefert) */
  int getFarbe() const;
  /** liefert die Version zurück. Wird nur noch von Hifea benutzt. */
  int getVersion() const;
  /** liefert true, wenn der Blop am platzen ist */
  bool getAmPlatzen() const;
  /** Liefert true, wenn wir uns mit b verbinden wollen. Auch hier dürfen
      wir allerdings nur die alten Var-Werte von b lesen */
  bool verbindetMit(const Blop & b) const;
  /** Sagt (ggf.) dem Feuer, wie es sich verbinden kann. */
  int getBesitzVerbindungen(int x, int y, bool feuer) const;
  /** liefert true, wenn sich der Blop auch mit dem angegebenen
      Rand verbindet */
  bool verbindetMitRand(int seite) const;
  /** Liefert zurück, wie viele Punkte dieser Stein zur Kettengröße
      beiträgt (normalerweise 1). */
  int getKettenBeitrag() const;
  /** Liefert zurück, ob ein bestimmtes Platzverhalten vorliegt */
  bool getVerhalten(int verhalten) const;
  /** Liefert zurück, welchem Spieler (0 oder 1) der Blop gehoert oder
      2 bei globalblop */
  int getSpieler() const;

  /** Liefert einen String der Art "Blop Drachen at x,y".
      Für Fehlermeldungen. */
  Str toString() const;

  /** Wird vom Code aufgerufen, wenn es Punkte geben soll. */
  void bekommPunkte(int pt) const;
  /** Wird vom Code aufgerufen, wenn ein Message angezeigt werden soll. */
  void zeigMessage(Str mess) const;

  const ort_absolut & getOrt() const;

 protected:
  /* Achtung! Beim Einfügen neuer Felder muss auch aendern(...) geändert werden.
     Und operator== vielleicht auch. */
	
  /** Die aktuelle Größe der Kette, in der dieser Blop hängt.
      Kann als spezconst abgefragt werden. Wird von setKettenGroesse()
      gesetzt. */
  int mKettenGroesse;
  
  /***** Variablen, die sich nie ändern *****/
  /* Sie sollten am besten const sein; das geht aber aus technischen Gründen
     beim BlopGitter nicht.
     Sie brauchen nur am Anfang einmal gesetzt zu werden, weil sie bei
     Zuweisungen nicht (mehr) verändert werden. */
  /** True, wenn noch nicht setBesitzer() aufgerufen wurde. Ist bei Blops
      der Fall, die grade in irgendwelchen Zwischenspeichervariablen
      rumliegen. Wird nur zu Fehlererkennungszwecken benötigt: Bei
      freilaufenden Blops darf kein Cual-Code ausgeführt werden. */
  bool mFreilaufend;
  /** ggf. Pointer auf den Besitzer dieses Blops */
  BlopBesitzer * mBesitzer;

  ort_absolut mOrt;
  
 protected: // Protected methods
  /** Liest die aktuelle Sorte (oder die vom Beginn der Gleichzeit) dieses
      Blops aus den Leveldaten aus. */
  Sorte * getSorte(bool vergangenheit = false) const;
  /** Fragt beim Besitzer an, in welche Richtungen dieser Blop
      verbunden werden kann und liefert das zurück. */
  int getVerbindungen() const;

  
  /***** Variablenverwaltung; Beziehung zum Code *****/

protected:

  /** Länge von mDaten. Sollte, wenn der Blop verwendet wird, auch
      immer mit ld->mLevelKnoten->getDatenLaenge() übereinstimmen. 
      (Dafür sorgen Konstruktoren und =-Operator.)*/
  int mDatenLaenge;
  /** Hier stehen die ganzen Variablen drin, die im Code definiert
      wurden. Man kann da 1. direkt drauf zugreifen oder 2. getVariable()
      und setVariable() verwenden. 1. sollte man tun, wenn man außerhalb
      einer Gleichzeit etwas tut; 2. sollte man innerhalb einer Gleichzeit
      tun, damit auch die zeitverzögerten Zugriffe funktionieren. */
  int * mDaten;
  /** Der alte Variablen-Wert. Wird benötigt, damit anderer Code nicht
      zu früh auf den neuen Wert zugreift. */
  int * mDatenAlt;
  
  /** Wenn etwas für alle Nachbarn berechnet wird, dann, wird das
      getan, indem die relativen Koordinaten hier eingestellt werden.
      D. h. getVariable() greift addiert noch diese Koordinaten. */
  //int mEvalNachbarDx;
  //int mEvalNachbarDy;
  
  /** Die Zeitnummer, zu dessen Anfang mDatenAlt gehört. */
  long mZeitNummerDatenAlt;
  /** Zeitnummer für initStapel-Lazy-Aufruf. */
  long mZeitNummerLeereStapel;
  
  /** Wird nur innerhalb von animiere() gebraucht, während ein
      Cual-Code läuft. True, wenn der Cual-Code malen darf. */
  bool mMalenErlaubt;
  
  /** Der aktuelle Bildstapel */
  BildStapel mBild;
  /** Der nicht mehr ganz aktuelle Bildstapel */
  BildStapel mBildAlt;

public:
  
  /* Macht alle Initialisierungen, die vor jedem Schritt gemacht
     werden */
  void initSchritt();


  int getSpezConst(int vnr, bool vergangenheit = false) const;  

  /** High-Level; Wird benutzt, wenn eine Variable im cual-Programm steht.
      Kümmert sich auch um all das @()-Zeug und die Zeitverzögerung. */
  int getVariable(const Variable & v);
  void setVariable(const Variable & v, int wert, int op);
  
  /** Low-Level; wird von den High-Level-Funktionen aufgerufen und vom
      Cual-Programm bei internen Variablen.
      Achtung: Fremdblops sollten *immer* die Zeitverschobenen Versionen
      benutzen. */
  int getVariable(int vnr) const;
  void setVariable(int vnr, int wert, int op);

private:
  /** Noch low-Levler: Speichert alte Werte nicht ab, wie sich das
      innerhalb einer Gleichzeit gehören würde. */
  void setVariableIntern(int vnr, int wert, int op);
  /** spezvar_kind ist eine ganz spezielle spezvar: Ganz lowlevel passiert
      hier noch mehr. */
  void setKindIntern(int wert);


public:
  inline bool getBoolVariable(int vnr) const {
    //CASSERT(mDatenLaenge == ld->mLevelKnoten->getDatenLaenge());
    //CASSERT((int) (vnr / bits_pro_int) < ld->mLevelKnoten->getDatenLaenge());
    return mDaten[vnr / bits_pro_int] & (1 << (vnr % bits_pro_int));
  }
  
  inline void setBoolVariable(int vnr, bool wert) {
    /* Vielleicht sollte man hier merkeAlteVarWerte() aufrufen. Das wäre
       nötig, wenn man für die Bool-Variablen vergangenheitslesen wollen
       würde. Will man aber nicht. Also brauchen wir auch nicht die alten
       Werte abzuspeichern. */

    //CASSERT(mDatenLaenge == ld->mLevelKnoten->getDatenLaenge());
    int pos = vnr / bits_pro_int;
    //CASSERT(pos < ld->mLevelKnoten->getDatenLaenge());
    int mask = 1 << (vnr % bits_pro_int);
    if (wert)
      mDaten[pos] |= mask;
    else
      mDaten[pos] &= ~mask;
  }

  /** Zeitverschobener Variablenzugriff: Fremdblops sollten immer diese
      Routinen verwenden. */
  /** Liefert den Wert der Variable zum Anfang der Gleichzeit zurück. */
  int getVariableVergangenheit(int vnr) const;
  /** Setzt die Variable am Ende der Gleichzeit. */
  void setVariableZukunft(int vnr, int wert, int op);

  /** Speichert, falls nötig, die Variablenwerte in mDatenAlt, für
      zeitverzögerten Variablenzugriff. Falls nötig bedeutet: Falls
      sie in dieser Gleichzeit noch nicht gespeichert wurden.
      Wird von set[Bool]Variable(vnr) aufgerufen, bevor eine Variable
      geändert wird. */
  void merkeAlteVarWerte();
  
  /** Schaut, ob noch ein Lazy-Evaluation-initStapel()-Aufruf aussteht
      und führt ihn ggf. aus. (Siehe lazyLeereStapel().)
      Ist zwar eigentlich nicht wirklich const, wird aber in Situationen
      aufgerufen, wo man sich eigentlich const fühlen möchte. */
  void braucheLeereStapel() const;
  
  /** Speichert das aktuelle Bild (d. h. aus den spezvar file und pos)
      in die Mal-Liste */
  void speichereBild();

  /** Speichert das aktuelle Bild (d. h. aus den spezvar file und pos)
      in die Mal-Liste von einem anderen Blop, und zwar so, dass es
      in Ebene ebene gemalt wird. */
  void speichereBildFremd(Ort & ort, int ebene);

protected:

  /** Nummer eines Events, das der Blop noch erwartet; event_keins, wenn
   *  der Blop kein Event erwartet. Wert nur mit den Methoden
   *  scheduleEvent() und unscheduleEvent() ändern, damit das auch
   *  in der globalen Liste aktualisiert wird.
   */
  int mScheduleEventNr;

  /** Wo in gSEListe steht dieser Blop (falls er ein Event will) */
  int mSEPos;

  /** Löscht diesen Blop aus gWEListe (falls nötig) */
  void unscheduleEvent();

  /** Liste der Blops, die ein Event wollen. */
  static std::vector<Blop *> gSEListe;

public:
  /** Ruft alle geschedulten Events aus. */
  static void sendeGeschedulteEvents();

  void playSample(int nr) const;


  /********** Statisches Zeug **********/
  
  

public:

  /** Wenn es für den Cual-Programmierer so aussehen soll, als würden Dinge
      gleichzeitig passieren (d. h. @ greift zeitverzögert zu), dann sollte
      man erst beginGleichzeitig() aufrufen, dann die ganzen Blop-Programm-
      aufrufe, und dann endGleichzeitig().
      */
  static void beginGleichzeitig();
  
  /** Siehe beginGleichzeitig(). */
  static void endGleichzeitig();

  /** Bricht eine Gleichzeit einfach ab. Wird beim Auftreten von Fehlern
      aufgerufen, und zwar vom Constructor von Fehler(). */
  static void abbruchGleichzeitig();
  
  /** Tut so, als würde es initStapel() für alle Blops aufrufen (d. h. die
      Grafiken löschen. In Wirklichkeit passiert das mit Lazy-Evaluation,
      d. h. erst dann, wenn's wirklich gebraucht wird.
      Gebraucht wird's natürlich, wenn ein Blop animiert wird. Aber auch,
      wenn ein Nachbarblop etwas auf diesen Blop malt. */
  static void lazyLeereStapel();
  
  /** Stellt ein, ob Blops */
  //static void setInitEventsAutomatisch(bool iea);

protected:
  /** True zwischen Aufrufen von beginGleichzeitig() und endGleichzeitig().
      Ist vermutlich nicht wirklich nötig, aber ich fühl mich damit wohler.
      */
  static bool gGleichZeit;
  /** Wird bei jeder Gleichzeit um eins hochgezählt. Jeder Blop hat auch
      so eine Variable. So weiß der Blop, ob er in dieser Zeit schon ein
      Programm hat laufen lassen. (Known Bug: Nach einigen Jahren Spielzeit
      passieren Fehler... man könnte diese Variable vor jedem Level frisch
      initialisieren.) */
  static long gAktuelleZeitNummerDatenAlt;
  /** Entsprechend für initStapel()-Aufrufe. D. h.: Wenn mZeitNummerLeereStapel
      eines Blops kleiner als gAktuelleZeitNummerLeereStapel ist, muss
      initStapel() noch aufgerufen werden. */
  static long gAktuelleZeitNummerLeereStapel;
  
  /** True heißt, dass neu erzeugte Blops automatish init-Events
      bekommen. (true ist default) */
  //static bool gInitEventsAutomatisch;
  
  /** Enthält alle Informationen für eine Zukunftszuweisung.
      (Welcher Blop, welche Variable, welcher neue Wert, welche Operation) */
  struct tZZ {
    Blop * mBlop; int mVNr; int mWert;
    /** "=", "+=", "-=", etc.; hat einen der Codeart-Werte set_code,
        add_code, sub_code, etc. */
    int mOperation;

    tZZ() {}
    tZZ(Blop * b, int vnr, int w, int op): mBlop(b), mVNr(vnr),
      mWert(w), mOperation(op) {}
  };

  /** Liste der Zukunfts-Zuweisungen, die sich während einer Gleichzeit
      ansammeln. */
  static std::vector<tZZ> gZZ;
  static int gZZAnz;


  /***** Für globales Animationszeug *****/  

public:  
  /** Der Blop, der ld->mGlobalCode ausführt. Wird am Ende von
      LevelDaten::ladLevel() initialisiert. */
  static Blop gGlobalBlop;
  
  
};

#endif
