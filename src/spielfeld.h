/***************************************************************************
                          spielfeld.h  -  description
                             -------------------
    begin                : Wed Jul 12 2000
    copyright            : (C) 2000 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2001-2007,2010,2011,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef SPIELFELD_H
#define SPIELFELD_H

#include <cstdlib>

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <SDL.h>

#include "blopgitter.h"
#include "fall.h"
#include "font.h"


#define graue_bei_kettenreaktion 5 // (grx - 1) // (grz - minflopp)

/* gibt an, um wie viele Pixel pro Zeitschritt sich alles beim Reihe-Rübergeben
   verschiebt; sollte Teiler von gric sein */
#define reihe_rueber_senkrecht_pixel 8



/* Für das Grafik-Update-System... */
#define ebene_hintergrund 0
#define ebene_blops 2
#define ebene_fall 3
#define ebene_hetzrand 4



/* Rückgabewerte für getFallModus(); wird vom KIPlayer benötigt. */
#define fallmodus_keins 0
#define fallmodus_neu 1
#define fallmodus_unterwegs 2



enum {
  infoblop_grey,
  infoblop_grass,
  infoblop_neighbours,
  infoblop_chainreaction,
  infoblop_anz
};


class KIPlayer;

/**
  *
  */

class Spielfeld {
public:
  Spielfeld(bool re);
  ~Spielfeld();
  /** sollte nur aufgerufen werden, wenn papa->spielLaeuft() false
      liefert; liefert
      true, wenn alle Spiel-Stop-Animationen fertig sind; liefert
      übrigens auch true,
      wenn dieser Spieler gar nicht mitspielt */
  bool bereitZumStoppen();
  /** Lässt den Hetzrand schnell runterkommen (für die
      Zeitbonus-Animation). Liefert true, wenn fertig. */
  bool bonusSchritt();
  /** Liefert true, wenn grade ein Fallendes unterwegs ist.
      Wird vom KIPlayer benötigt */
  int getFallModus() const;
  /** Liefert einen Pointer auf das Blopgitter zurück. */
  BlopGitter * getDatenPtr();
  /** Liefert einen Pointer auf die fallendne Blops zurück.
      Wird von KIPlayer einmal am Anfang aufgerufen
      und von ort_absolut::finde(). */
  const Blop * getFall(int which = 0) const;
  Blop * getFall(int which = 0);
  int getFallAnz() const;
  /** Ersetzt das Fall durch ein neues, das wieder von ganz oben startet.
      Aber nur, wenn noch beide Hälften dran sind. */
  void resetFall();
  Blop & getSemiglobal();
  /** Liefert die Pos. zurück, an der neue Dinge oben
      auftauchen. */
  int getHetzrandYAuftauch() const;
  /** Liefert die Pos. zurück, bis wohin noch Dinge liegen
      dürfen, ohne dass man tot ist. */
  int getHetzrandYErlaubt() const;
  /** Liefert die Pos. vom Hetzrand in Pixeln zurück. Wird
      vom Fall gebraucht. */
  int getHetzrandYPix() const ;
  /** Ändert die Höhe vom Hetzrand auf y (in Pixeln). */
  void setHetzrandYPix(int y);
  /** Liefert die (rüberreihenbedingte) Hochverschiebung
      des gesamten Spielfelds. Wird vom Fall benötigt (um
      seine Koordinaten in Feldern zu berechnen). */
  int getHochVerschiebung() const;
  /** Liefert die Koordinaten eines Felds in Pixeln zurück (ungespiegelt) */
  void getFeldKoord(int x, int y, int & xx, int & yy) const;

  /** Zeigt t groß an. (Oder weniger groß.) */
  void setText(const Str & t, bool kleine_schrift = false,
	       int x0 = 0, int x1 = gric*grx);
  
  /** Für während des Spiels: Setzt einen Text, der ein paar mal
      aufblinkt. */
  void setMessage(Str mess);

  /** Setzt das Rechteck x, y, w, h auf upzudaten. */
  void setUpdateRect(int x, int y, int w, int h);
  /** Setzt alles auf upzudaten. */
  void setUpdateAlles();
  /** Setzt das nächste Fall auf upzudaten... und die Infblops */
  void setUpdateNaechstesFall();

  /** Hauptmalroutine: Malt alles, was sich geaendert hat, neu */
  void malUpdateAlles();
  /** Malt (falls noetig) das nächste Fall neu... und die Infoblops */
  void malUpdateNaechstesFall();

  int getZeit() const;
  
  /** Liefert true, wenn diese Spalte um gric/2 verschoben ist (wegen Hex-Modus) */
  bool getHexShift(int x) const;
 protected:
  /** Malt die ganzen Blops, usw. */
  void malUpdateSpielsituation();
  /** Malt die Schrift auf den Bildschirm */
  void malSchrift(bool mitte /*= true*/,
                  const FontStr & text,
		  int x0, int x1);
  /** Wenn der Level gespiegelt ist, wird auch das Rechteck gespiegelt. */
  void spiegelRect(SDL_Rect & r);

  /** liefert die Höhe vom höchsten Türmchen */
  int getHoehe();
  /** berechnet, ob und welche Blops platzen müssen. Außerdem
      werden den Blops die Kettengrößen mitgeteilt, und Graue
      und Punkte verteilt */
  bool calcFlopp();
  /** sucht die Zusammenhangskomponente von x, y mit Farbe n.
      Setzt in flopp[][] an den entspr. Stellen das Bit w.
      Aufruf mit w = 1 um rauszufinden, ob genug gleichfarbige beisammen sind;
      liefert Anzahl der gleichfarbigen zurück;
      Danach Aufruf mit w = 2 und richtigem anz-Wert, um den Blops ihre neue
      Kettengröße mitzuteilen.
      Liefert Anzahl der Punkte zurück, die's dafür gibt (wenn Blops platzen).
      Nur wenn platzen = true ist, wird platzen durchgeführt.
      Sonst bekommen die
      Blops nur ihre Kettengröße mitgeteilt.
      @return Je nach w Größe der Zshgskomp. oder Anz. d. Punkte */
  int calcFloppRec(int flopp[grx][gry], int x, int y,
		   int n, int w, bool platzen = false,
		   bool ist_kettenreaktion = false, int anz = 0);
  /** verschiebt einen Blop (auch wenn er explodiert oder sonstwie
      grad animiert ist). Was dort hin soll, von wo der Blop weg ist
      (z. B. blopart_wirklich_keins) kann übergeben werden. */
  void verschiebBlop(int x1, int y1, int x2, int y2,
		     int bg_sorte = blopart_keins);
  /** Lässt in der Luft hängende Blops ein Stück runterfallen.
      Liefert zurück, ob sich nichts bewegt hat, nur unten oder auch
      oben. Bei auchGraue = true, kommen auch Graue, die ganz über
      dem Spielfeld hängen. */
  int rutschNach(bool auchGraue);
  public:
  /** Kümmert sich um hin- und hergeben von Reihen. */
  void rueberReihenSchritt();
  protected:
  /** Prüft, ob ein Reihenbekommen sinnvoll wäre und initiiert es ggf.
      (Unterhält sich auch mit dem anderen Spieler). Liefert true,
      wenn es jetzt grad nicht möglich war, eine Reihe zu bekommen,
      aber nur weil der andere Spieler noch damit beschäftigt war,
      von einer vorigen Reihe sein Spielfeld runterzuschieben. Unter
      manchen Umständen wird dann später nochmal probiert, eine
      Reihe zu bekommen. */
  bool bekommVielleichtReihe();


  /***** Variablen, die die ganze Zeit konstant sind *****/
  
	
  /** true, wenn rechter von den beiden Spielern */
  bool mRechterSpieler;

  /***** Variablen, die sich häufig ändern *****/

  /** Text, der grade angezeigt wird (falls das Spiel nicht läuft) */
  FontStr mText;
  /** True, wenn die Schrift von mText klein sein soll. */
  bool mTextKlein;
  /** Horizontal clipping coordinates for mText. */
  int mTextX0,mTextX1;
  /** Text, der grade blinkt */
  Str mMessageText;
  /** Blink-Zeitzähler. */
  int mMessageZeit;
		
  /** _die_ Spielfelddaten */
  BlopGitter mDaten;
  /** Alle Fall-Daten (Pointer, damit "mFall = mNaechsterFall" keine Daten rumschieben muss) */
  Fall *mFall;
  Fall *mNaechsterFall;
  /** Der semi-globale Blop */
  Blop mSemiglobal;
  /** Die Info-Blops */
  Blop mInfoBlops[infoblop_anz];
  bool mInfoBlopActive[infoblop_anz];
  /** Zeit innerhalb des Levels */
  int mZeit;
  /** Höhe in Pixeln vom Rand, der mit der Zeit runterkommt,
      damit der Level nicht so ewig geht */
  int mHetzrandYPix;
  /** Höhe in Feldern vom Rand */
  int mHetzrandY;
  /** True, wenn das Fall grade frisch aufgetaucht ist. Der KI-Player will
      das wissen. */
  bool mFallIstNeu;
  /** eigentlicher Modus */
  int mModus;
  /** Aktueller Stand des Reihen hin- und hergebens. */
  int mRueberReihenModus;
  /** True, wenn wir so lange probieren, eine Reihe zu bekommen, bis
      der andere Spieler sagt, dass wir wirklich keine bekommen. */
  bool mWillHartnaeckigReihe;
  /** Aktuelle Pos. der Reihe beim Rüberrutschen. */
  int mRestRueberReihe;
  /** true, wenn grade schon was geplatzt ist.
      Wird auf false gesetzt, wenn ein fallendes aufkommt und auf true, wenn
      etwas fertig geplatzt ist. */
  bool mKettenreaktion;
  /** Anzahl der Grauen, die darauf warten, runterzukommen */
  int mGrauAnz;
  int mGrasAnz;
  /** != 0 während des Reihen hin und hergebens. Um so viele Pixel ist das
      gesamte Spielfeld nach oben verschoben. */
  int mHochVerschiebung;


  /* Die folgenden Variablen geben an, was von malUpdate() neu gemalt werden
     soll. Sie sollten nur von setUpdateRect() u.ae. geändert werden. */
  bool mUpdateBlop[grx][gry + 2];  // welche einzelnen Blops neu malen (inkl. Hexmodus-Unterrand)
  bool mUpdateAlles;   // true heisst: alles neu malen
  bool mUpdateNaechstesFall;

 private:
  /* Liefert zurueck, zu wie vielen Nachbarblops sich Blop b
     an Position x,y verbinden wuerde.
     Wird von createStartDist() verwendet. */
  int blopVerbindungen(const Blop & b, int x, int y);
 
  /* Startdist aus Leveldaten auslesen und ins Spielfeld schreiben */
  void createStartDist();
	
 public:
  /** Schaltet die Spielfeld-Anzeige aus, damit "Loading level"
      angezeigt werden kann... */
  void ladeLevelModus();
  /** Initialisiert alles für's Spiel. Schaltet die Spielfeldanzeige an.
      Muss in einer Gleichzeit aufgerufen werden, für die init-Events. 
      Danach muss noch einmal animiere() aufgerufen werden, damit alle
      Blops wissen, wie sie aussehen, und damit die Grafik gemalt wird. */
  void startLevel();
  /** Spiel abbrechen (sofort, ohne Animation; oder die
      Animation ist schon vorbei). */
  void stopLevel();
  
  
  /***** Funktionen, die einmal pro Spielschritt aufgerufen werden *****/

  /** Um Fall kümmern. (Aber nicht darum, neues Fall zu erzeugen). */
  void fallSchritt();
  
  /** kümmert sich ggf. um blinkendes Message */
  void blinkeMessage();
  
  /** Sorgt dafür, dass bei Spielende bei geeigneter Gelegenheit auch in diesem
      Spielfeld das Spiel beendet wird */
  void testeSpielende();

  /** Bewegt den Hetzrand eins nach unten. Testet auch, ob dabei
      was überdeckt wird. */
  void bewegeHetzrand();
  
  /** Sendet sich selbst (ggf.) zufällige Graue */
  void zufallsGraue();
 
  /** Zusammenhangskomponenten bestimmen und ggf. Explosionen auslösen */
  void testeFlopp();
 
  /** Ein Schritt vom Spiel.
      Animationen wird *nicht* gemacht. Dazu muss animiere() aufgerufen werden.
      (Weil alle Animationen innerhalb einer eigenen Gleichzeit
      stattfinden sollen.)
      spielSchritt() sollte innerhalb einer Gleichzeit aufgerufen
      werden für evtl. auftretende Events. */
  void spielSchritt();
  /** Führt alle Animationen durch.
      Sollte innerhalb einer Gleichzeit aufgerufen werden.
      ZÃ¤hlt auch die Gras-Blobs neu durch. */
  void animiere();
  
  
  
  
  
  /** Führt eine der nachfolgenden Tasten-Routinen aus.
      (t = taste_*). */
  void taste(int t);
  /** Bewegt das Fall eins nach links */
  void tasteLinks();
  /** Bewegt das Fall eins nach rechts */
  void tasteRechts();
  /** Dreht das Fall */
  void tasteDreh();
  /** Ändert die Fallgeschwindigkeit vom Fall */
  void tasteFall();

 public:
  /** Graue von anderem Spieler bekommen; wird ignoriert, falls dieser
      Spieler grad nicht spielt */
  void empfangeGraue(int g);
  int getGrauAnz() const;
  int getGrasAnz() const;
  /** liefert zurück, ob wir dem anderen
      Spieler eine Reihe geben (er hat Höhe h); Antwort ist
      eine der Konstanten bewege_reihe_xxx */
  int bitteUmReihe(int h);
  /** gibt einen Stein an den anderen Spieler
      rüber; Blop wird in s zurückgeliefert */
  void gebStein(Blop & s);
};

#endif

