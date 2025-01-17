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

#include <SDL2/SDL.h>

#include "blopgitter.h"
#include "fall.h"
#include "font.h"


#define graue_bei_kettenreaktion 5 // (grx - 1) // (grz - minflopp)

/* gibt an, um wie viele Pixel pro Zeitschritt sich alles beim Reihe-R�bergeben
   verschiebt; sollte Teiler von gric sein */
#define reihe_rueber_senkrecht_pixel 8



/* F�r das Grafik-Update-System... */
#define ebene_hintergrund 0
#define ebene_blops 2
#define ebene_fall 3
#define ebene_hetzrand 4



/* R�ckgabewerte f�r getFallModus(); wird vom KIPlayer ben�tigt. */
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
      �brigens auch true,
      wenn dieser Spieler gar nicht mitspielt */
  bool bereitZumStoppen();
  /** L�sst den Hetzrand schnell runterkommen (f�r die
      Zeitbonus-Animation). Liefert true, wenn fertig. */
  bool bonusSchritt();
  /** Liefert true, wenn grade ein Fallendes unterwegs ist.
      Wird vom KIPlayer ben�tigt */
  int getFallModus() const;
  /** Liefert einen Pointer auf das Blopgitter zur�ck. */
  BlopGitter * getDatenPtr();
  /** Liefert einen Pointer auf die fallendne Blops zur�ck.
      Wird von KIPlayer einmal am Anfang aufgerufen
      und von ort_absolut::finde(). */
  const Blop * getFall(int which = 0) const;
  Blop * getFall(int which = 0);
  int getFallAnz() const;
  /** Ersetzt das Fall durch ein neues, das wieder von ganz oben startet.
      Aber nur, wenn noch beide H�lften dran sind. */
  void resetFall();
  Blop & getSemiglobal();
  /** Liefert die Pos. zur�ck, an der neue Dinge oben
      auftauchen. */
  int getHetzrandYAuftauch() const;
  /** Liefert die Pos. zur�ck, bis wohin noch Dinge liegen
      d�rfen, ohne dass man tot ist. */
  int getHetzrandYErlaubt() const;
  /** Liefert die Pos. vom Hetzrand in Pixeln zur�ck. Wird
      vom Fall gebraucht. */
  int getHetzrandYPix() const ;
  /** �ndert die H�he vom Hetzrand auf y (in Pixeln). */
  void setHetzrandYPix(int y);
  /** Liefert die (r�berreihenbedingte) Hochverschiebung
      des gesamten Spielfelds. Wird vom Fall ben�tigt (um
      seine Koordinaten in Feldern zu berechnen). */
  int getHochVerschiebung() const;
  /** Liefert die Koordinaten eines Felds in Pixeln zur�ck (ungespiegelt) */
  void getFeldKoord(int x, int y, int & xx, int & yy) const;

  /** Zeigt t gro� an. (Oder weniger gro�.) */
  void setText(const Str & t, bool kleine_schrift = false,
	       int x0 = 0, int x1 = gric*grx);
  
  /** F�r w�hrend des Spiels: Setzt einen Text, der ein paar mal
      aufblinkt. */
  void setMessage(Str mess);

  /** Setzt das Rechteck x, y, w, h auf upzudaten. */
  void setUpdateRect(int x, int y, int w, int h);
  /** Setzt alles auf upzudaten. */
  void setUpdateAlles();
  /** Setzt das n�chste Fall auf upzudaten... und die Infblops */
  void setUpdateNaechstesFall();

  /** Hauptmalroutine: Malt alles, was sich geaendert hat, neu */
  void malUpdateAlles();
  /** Malt (falls noetig) das n�chste Fall neu... und die Infoblops */
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

  /** liefert die H�he vom h�chsten T�rmchen */
  int getHoehe();
  /** berechnet, ob und welche Blops platzen m�ssen. Au�erdem
      werden den Blops die Kettengr��en mitgeteilt, und Graue
      und Punkte verteilt */
  bool calcFlopp();
  /** sucht die Zusammenhangskomponente von x, y mit Farbe n.
      Setzt in flopp[][] an den entspr. Stellen das Bit w.
      Aufruf mit w = 1 um rauszufinden, ob genug gleichfarbige beisammen sind;
      liefert Anzahl der gleichfarbigen zur�ck;
      Danach Aufruf mit w = 2 und richtigem anz-Wert, um den Blops ihre neue
      Kettengr��e mitzuteilen.
      Liefert Anzahl der Punkte zur�ck, die's daf�r gibt (wenn Blops platzen).
      Nur wenn platzen = true ist, wird platzen durchgef�hrt.
      Sonst bekommen die
      Blops nur ihre Kettengr��e mitgeteilt.
      @return Je nach w Gr��e der Zshgskomp. oder Anz. d. Punkte */
  int calcFloppRec(int flopp[grx][gry], int x, int y,
		   int n, int w, bool platzen = false,
		   bool ist_kettenreaktion = false, int anz = 0);
  /** verschiebt einen Blop (auch wenn er explodiert oder sonstwie
      grad animiert ist). Was dort hin soll, von wo der Blop weg ist
      (z. B. blopart_wirklich_keins) kann �bergeben werden. */
  void verschiebBlop(int x1, int y1, int x2, int y2,
		     int bg_sorte = blopart_keins);
  /** L�sst in der Luft h�ngende Blops ein St�ck runterfallen.
      Liefert zur�ck, ob sich nichts bewegt hat, nur unten oder auch
      oben. Bei auchGraue = true, kommen auch Graue, die ganz �ber
      dem Spielfeld h�ngen. */
  int rutschNach(bool auchGraue);
  public:
  /** K�mmert sich um hin- und hergeben von Reihen. */
  void rueberReihenSchritt();
  protected:
  /** Pr�ft, ob ein Reihenbekommen sinnvoll w�re und initiiert es ggf.
      (Unterh�lt sich auch mit dem anderen Spieler). Liefert true,
      wenn es jetzt grad nicht m�glich war, eine Reihe zu bekommen,
      aber nur weil der andere Spieler noch damit besch�ftigt war,
      von einer vorigen Reihe sein Spielfeld runterzuschieben. Unter
      manchen Umst�nden wird dann sp�ter nochmal probiert, eine
      Reihe zu bekommen. */
  bool bekommVielleichtReihe();


  /***** Variablen, die die ganze Zeit konstant sind *****/
  
	
  /** true, wenn rechter von den beiden Spielern */
  bool mRechterSpieler;

  /***** Variablen, die sich h�ufig �ndern *****/

  /** Text, der grade angezeigt wird (falls das Spiel nicht l�uft) */
  FontStr mText;
  /** True, wenn die Schrift von mText klein sein soll. */
  bool mTextKlein;
  /** Horizontal clipping coordinates for mText. */
  int mTextX0,mTextX1;
  /** Text, der grade blinkt */
  Str mMessageText;
  /** Blink-Zeitz�hler. */
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
  /** H�he in Pixeln vom Rand, der mit der Zeit runterkommt,
      damit der Level nicht so ewig geht */
  int mHetzrandYPix;
  /** H�he in Feldern vom Rand */
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
  /** Aktuelle Pos. der Reihe beim R�berrutschen. */
  int mRestRueberReihe;
  /** true, wenn grade schon was geplatzt ist.
      Wird auf false gesetzt, wenn ein fallendes aufkommt und auf true, wenn
      etwas fertig geplatzt ist. */
  bool mKettenreaktion;
  /** Anzahl der Grauen, die darauf warten, runterzukommen */
  int mGrauAnz;
  int mGrasAnz;
  /** != 0 w�hrend des Reihen hin und hergebens. Um so viele Pixel ist das
      gesamte Spielfeld nach oben verschoben. */
  int mHochVerschiebung;


  /* Die folgenden Variablen geben an, was von malUpdate() neu gemalt werden
     soll. Sie sollten nur von setUpdateRect() u.ae. ge�ndert werden. */
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
  /** Initialisiert alles f�r's Spiel. Schaltet die Spielfeldanzeige an.
      Muss in einer Gleichzeit aufgerufen werden, f�r die init-Events. 
      Danach muss noch einmal animiere() aufgerufen werden, damit alle
      Blops wissen, wie sie aussehen, und damit die Grafik gemalt wird. */
  void startLevel();
  /** Spiel abbrechen (sofort, ohne Animation; oder die
      Animation ist schon vorbei). */
  void stopLevel();
  
  
  /***** Funktionen, die einmal pro Spielschritt aufgerufen werden *****/

  /** Um Fall k�mmern. (Aber nicht darum, neues Fall zu erzeugen). */
  void fallSchritt();
  
  /** k�mmert sich ggf. um blinkendes Message */
  void blinkeMessage();
  
  /** Sorgt daf�r, dass bei Spielende bei geeigneter Gelegenheit auch in diesem
      Spielfeld das Spiel beendet wird */
  void testeSpielende();

  /** Bewegt den Hetzrand eins nach unten. Testet auch, ob dabei
      was �berdeckt wird. */
  void bewegeHetzrand();
  
  /** Sendet sich selbst (ggf.) zuf�llige Graue */
  void zufallsGraue();
 
  /** Zusammenhangskomponenten bestimmen und ggf. Explosionen ausl�sen */
  void testeFlopp();
 
  /** Ein Schritt vom Spiel.
      Animationen wird *nicht* gemacht. Dazu muss animiere() aufgerufen werden.
      (Weil alle Animationen innerhalb einer eigenen Gleichzeit
      stattfinden sollen.)
      spielSchritt() sollte innerhalb einer Gleichzeit aufgerufen
      werden f�r evtl. auftretende Events. */
  void spielSchritt();
  /** F�hrt alle Animationen durch.
      Sollte innerhalb einer Gleichzeit aufgerufen werden.
      Zählt auch die Gras-Blobs neu durch. */
  void animiere();
  
  
  
  
  
  /** F�hrt eine der nachfolgenden Tasten-Routinen aus.
      (t = taste_*). */
  void taste(int t);
  /** Bewegt das Fall eins nach links */
  void tasteLinks();
  /** Bewegt das Fall eins nach rechts */
  void tasteRechts();
  /** Dreht das Fall */
  void tasteDreh();
  /** �ndert die Fallgeschwindigkeit vom Fall */
  void tasteFall();

 public:
  /** Graue von anderem Spieler bekommen; wird ignoriert, falls dieser
      Spieler grad nicht spielt */
  void empfangeGraue(int g);
  int getGrauAnz() const;
  int getGrasAnz() const;
  /** liefert zur�ck, ob wir dem anderen
      Spieler eine Reihe geben (er hat H�he h); Antwort ist
      eine der Konstanten bewege_reihe_xxx */
  int bitteUmReihe(int h);
  /** gibt einen Stein an den anderen Spieler
      r�ber; Blop wird in s zur�ckgeliefert */
  void gebStein(Blop & s);
};

#endif

