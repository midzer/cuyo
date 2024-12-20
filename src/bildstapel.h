/***************************************************************************
                          bildstapel.h  -  description
                             -------------------
    begin                : Thu Jul 20 2000
    copyright            : (C) 2000 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2002,2003,2005,2006,2011,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef BILDSTAPEL_H
#define BILDSTAPEL_H


#include <SDL.h>

/** So viele Bilder dürfen höchstens für einen Blop gemalt werden. */
#define max_bild_anz 20


/* Für spezvar_outX, wenn nix ausgegeben werden soll. */
#define spezvar_out_nichts 0x7fff



#define bildstapel_min_ebene (-1)
#define bildstapel_max_ebene 1



class Sorte;



/** Enthält die komplette Information darüber, wie ein blop grade
    aussieht. Also:
    - Eine Liste von Bildern, die gemalt werden müssen. Für jedes Bild:
      - Sorte (Achtung: Muss nicht mit der aktuellen Blop-Sorte
        übereinstimmen, wenn sich der Blop grade verwandelt hat. Oder
	wenn ein Nachbarblob hier her gemalt hat.);
        Datei-Nr; Pos; Viertel
    - Platz-Zustand des Blops. (Ist vielleicht etwas unschön, dass das
      die einzige Stelle ist, wo sich ein Blop seinen Platz-Zustand merkt.
      ist aber ja eigentlich auch egal.)
    - Eventuelle Debug-Output-Werte
    
    Das existiert vor allem deshalb als eigenständiges Objekt, damit man
    einen aktuellen Bildstapel mit einem veralteten vergleichen kann (um
    zu wissen, ob man den Blob neu malen muss).
    
    Verwendung:
    - Erst initStapel() aufrufen. Dann mit speichereBild() die gewünschten
      Bilder speichern.
    - Mit == kann verglichen werden, ob zwei Bildstapel das selbe malen.
    - Mit malen() kann der Stapel tatsächlich gemalt werden.
    
    */

class BildStapel {

  /** Eine Ebene des BildStapels */
  struct BildEbene {
    const Sorte * mSorte;
    int mDat;
    int mPos;
    int mViertel;
    int ebene;
    
    bool operator==(const BildEbene & e2) const {
      return mSorte == e2.mSorte &&
        mDat == e2.mDat && mPos == e2.mPos && mViertel == e2.mViertel &&
	ebene == e2.ebene;
    }
  };



  /** Maximale Stapelhöhe. Wird aus den Leveldaten ausgelesen. */
  int mMaxAnz;
  /** Tatsächliche Stapelhoehe */
  int mAnz;
  
  BildEbene * mStapel;
  
  /** Die Debug-Zahlen, die über das Blob geschrieben werden sollen. */
  int mDebugOut1, mDebugOut2;
  
  /** Aktueller Platz-Zustand. */
  int mAmPlatzen;


public:

  /** Erzeugt einen uninitialisierten Bildstapel */
  BildStapel(bool);

  BildStapel();

  ~BildStapel();
  
  BildStapel & operator=(const BildStapel & b);
  
private:
  void kopiere(const BildStapel & b);

  void deepCreate();
  void deepLoesch();
  
public:
  bool operator==(const BildStapel & b) const;

  /** Entfernt alle Bilder. Aufrufen, bevor
      speichereBild() für jedes Bild aufgerufen wird. */
  void initStapel(int platz);
 
  void speichereBild(Sorte * so, int dat, int pos, int viertel, int ebene = 0);
  
  void setDebugOut(int d1, int d2);
    
  /** malt den Bildstapel. xx und yy sind in Pixeln angegeben;
      Stimmt die folgende Behauptung??
      der Hintergrund wird vorher gelöscht.
      If apply_mirror is set and the level is an upside-down one, then the
      respective coordinate-transformation is applied. */
  void malen(int xx, int yy, bool apply_mirror=true) const;

  /** Liefert true, wenn der Stapel initialisiert ist */
  bool istInitialisiert() const;

  
  /** Liefert true, wenn der Stapel leer ist. Wird benutzt, um
      eine Fehlermeldung auszuspucken, wenn während eines Events
       gemalt wird. */
  bool istLeer() const;
 
  /** Für Debug-Ausgaben */ 
  void print() const;

private:
  /** Gibt die Zahl n aus. Wird für Debug-Output von malen()
      benutzt. */
  void malDebug(int xx, int yy, int n) const;
};







#endif
