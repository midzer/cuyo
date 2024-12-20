/***************************************************************************
                          bilddatei.h  -  description
                             -------------------
    begin                : Fri Apr 20 2001
    copyright            : (C) 2001 by Immi
    email                : cuyo@karimmi.de

Modified 2001,2002,2006,2008,2010,2011 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef BILDDATEI_H
#define BILDDATEI_H

#include <SDL.h>
#include <vector>

#include "sdltools.h"
#include "maske.h"
#include "stringzeug.h"


/* Zur Übergabe an malBildchen(): Welches Viertel soll gemalt werden?
   Entweder viertel_alle übergeben oder
   viertel_q** | viertel_z**
   Ersteres (Quelle) gibt an, welches Viertel aus der Datei genommen wird,
   zweiteres (Ziel) in welches Viertel gemalt wird.
*/
#define viertel_alle (-1)

/* Achtung: Wenn die nachfolgenden Konstanten geändert werden, muss
   auch const_werte in blop.cpp geändert werden. */
#define viertel_qlo 0
#define viertel_qro 1
#define viertel_qlu 2
#define viertel_qru 3

#define viertel_zlo 0
#define viertel_zro 4
#define viertel_zlu 8
#define viertel_zru 12

/* Bit-Masken... */
#define viertel_qr 1
#define viertel_qu 2
#define viertel_zr 4
#define viertel_zu 8

/* Für range-Check (siehe BildStapel::speichereBild()) */
#define viertel_min (-1)
#define viertel_max 15




class BildOriginal;

/**verwaltet ein xpm als Ansammlung von 16x16-Bildchen; und auch sonstige
  *Bilder. Kümmert sich insbesondere um Umfärbung und Bildschirmskalierung
  */

class Bilddatei {
 public: 
  Bilddatei();
  ~Bilddatei();
  
  void datenLoeschen();

  /* Für gleiche Quelle aber unabhängige Nachbearbeitung.
     Diese wird gleich schon mal in Form einer Umfärbung vollzogen. */
  Bilddatei(Bilddatei *, const Color &);


  /** Lädt das Bild mit dem angegebenen Namen. Sucht in verschiedenen
      Pfaden danach.Throwt ggf. */
  void laden(Str name);
  void klonen(Bilddatei & quelle);

  void setFaerbung(const Color & faerbung);
		
  /** malt das k-te Viertel vom n-te Bildchen an xx,yy. Oder evtl. das
      ganze Bildchen */
  void malBildchen(int xx, int yy, int n, int k = viertel_alle) const;
  /** liefert zurück, wie viele Bildchen in dieser Datei sind. */
  int anzBildchen() const;
  /** malt das gesamte Bild */
  void malBild(int xx, int yy) const;
  /** malt einen beliebigen Bildausschnitt */
  void malBildAusschnitt(int xx, int yy, const SDL_Rect & src) const;
  /* Malt das angegebene Rechteck (bzw. Teile davon) so oft, dass
     ein horizontaler Streifen der Länge l entsteht. Geht davon aus,
     das in dem Bildchen das src-Rechteck horizontal einheitlich ist.
     Je größer src, desto schneller geht das malen. */
  void malStreifenH(int xx, int yy, int l, const SDL_Rect & src) const;
  /* Das selbe in vertikal */
  void malStreifenV(int xx, int yy, int l, const SDL_Rect & src) const;
  /** liefert die Gesamtbreite in Pixeln zurück */
  int getBreite() const;
  /** liefert die Gesamthoehe in Pixeln zurück */
  int getHoehe() const;

  /** liefert true, wenn das Bild (erfolgreich) geladen ist */
  bool istGeladen() const {return mBild != 0;}
  
  /** Nur zum anschauen, nicht zum veraendern! Liefert das Bild in unskaliert
      und 32 Bit. */
  SDL_Surface * getSurface() const;

  void setAsBackground(int y);

 protected:
  /** Macht aus dem Original-Bild die gefaerbte und auf Bildschirmformat
      gebrachte Version (mBild). */
  void bildNachbearbeiten();

  BildOriginal * mBildOriginal;
  SDL_Surface * mBild;
  SDL_Surface * mNativBild;
    /* Eine Kopie von mBild im Format des Screen-Surfaces.
       Ist NULL, bis es gebraucht wird. */
  RohMaske mMaskeOriginal;
  Maske mMaske;
  int mBreite, mHoehe;
  Str mName; // Fuer bessere Fehlermeldungen
  bool mGefaerbt;
  Color mFaerbung;
  int mScale;
  
 public:
  /** Ggf. alle existierenden Bildchen reskalieren. */
  static void resizeEvent();
 
 protected:
  void sorgeFuerNativBild();
  void loescheAusZentralregister();

  /* Liste aller geladenen Bilddateien */
  static std::vector<Bilddatei *> * gAlleBilddateien;

 public:
  static void init();
  static void destroy();
};


/* Automatically colorize Bilddateien in a color which
   may change; use addUser to add Bilddateien which should
   use this color; use setColor to change the color of
   all users.
   It is the responsibility of the caller of setColor()
   to redraw the screen if necessary */
class AutoColor {

  Color mColor;
  
  std::vector<Bilddatei *> mUser;
  
 public:
  void setColor(const Color & c);
  void addUser(Bilddatei * b);
  
  void operator=(const Color & c);
  
  
  static AutoColor gGame;
};


#endif
