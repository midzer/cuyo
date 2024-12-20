/***************************************************************************
                          blatt.h  -  description
                             -------------------
    begin                : Mit Jul 12 22:54:51 MEST 2000
    copyright            : (C) 2006 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2006,2008,2010,2011 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef BLATT_H
#define BLATT_H

#include <vector>
#include <SDL.h>

#include "stringzeug.h"
#include "inkompatibel.h"
#include "punktefeld.h"

#include "leveldaten.h" // wegen grx, gry, max_spielerzahl; sollte woanders hin



enum {
  blattpic_pfeile,
  blattpic_highlight,
  blattpic_titel,
  blattpic_scroll,
  blattpic_scrollbright,
  blattpic_scrolldimmed,
  blattpic_border,
  blattpic_borderh,
  blattpic_borderv,
  blattpic_infoicons,
  anz_blattpics
};

/* Menüpunkte werden an verschiedenen Linien zentriert. Die Positionen
   dieser Linien werden getrennt berechnet. Siehe BlattMenu::oeffnen */
enum ZentrierLinie {
  zl_zentriert, zl_accel, zl_daten, zl_anzahl
};


class BlattMenu;


class Blatt {

public:
  virtual ~Blatt() {}

  virtual void doEvent(const SDL_Event & evt);
  virtual void keyEvent(const SDL_keysym & ) {}
  virtual void resizeEvent() {}
  virtual void mouseButtonEvent(bool , int , int ) {}
  virtual void mouseMotionEvent(bool , int , int  , int , int) {}
  virtual void anzeigen() = 0;
  
  virtual void zeitSchritt() {}

 /* Global-Zeug */
  static Bilddatei * gBlattPics[anz_blattpics];

  static void initBlaetter();
  static void destroyBlaetter();
};




class BlattSpiel: public Blatt {

  /** Die Punkte-Anzeigen */
  Punktefeld * mPunktefeld[max_spielerzahl];
  bool mDekoUpdaten;

 public:
  BlattSpiel();
  ~BlattSpiel();

  virtual void oeffnen(int lnr);
  virtual void keyEvent(const SDL_keysym & taste);
  virtual void resizeEvent();
  virtual void anzeigen();
  virtual void zeitSchritt();
  
  void randNeuMalen();
  void setPunkte(int sp, int pt);
 
 private:
  void malInfos(int sp, int x);
};





class MenuEintrag;


/* Konstanten für mausbereich.mEintrag */
#define eintrag_keiner (-1)
#define eintrag_scrollleiste (-2)

/* Der einzige Subbereich, der für Tastatur-User existiert. */
#define subbereich_default 0
/* Die folgenden Konstanten sind nur zur Übergabe von oder an
   Funktionen und nicht zum Speichern in einem MausBereich. */
#define subbereich_hyperaktiv (-2)
#define subbereich_keiner (-1)
#define subbereich_keinStrom (-3)
#define subbereich_nichtInitialisiert (-4)

struct MausBereich {

  int mEintrag;
  /* Die Bedeutung von subbereich hängt von der Menüeintragart ab.
     Subbereich ist nur für Maususer. Aus Sicht von Tastatur-Usern
     gibt es nur den default-Subbereich. (Sobald eine Taste gedrückt
     wird, sollte auch wieder dort hin geschaltet werden.) */
  int mSubBereich;
  
  MausBereich(): mEintrag(eintrag_keiner) {}
  explicit MausBereich(int e): mEintrag(e), mSubBereich(subbereich_default) {}
  MausBereich(int e, int sb): mEintrag(e), mSubBereich(sb) {}
  
  bool operator==(const MausBereich & m) const {
    if (mEintrag != m.mEintrag)
      return false;
    if (mEintrag == eintrag_keiner)
      return true;
    return mSubBereich == m.mSubBereich;
  }
};



class MenuEintragSubmenu;

enum yneuwahl {   /* Zur Übergabe an calcScroll():
		     wo (vertikal) soll der mWahl-Eintrag stehen? */
  ynw_mitte,
  ynw_oben,
  ynw_unten
};

class BlattMenu: public Blatt {
  friend struct DrawDing;
  friend class MenuEintrag;  /* Damit Menüpunkte doEscape() aufrufen können */

 protected:
  /* Soll es auch dann eine Scrollleiste haben, wenn sie unnötig ist?
     (=> hat auch escape-button) */
  bool mImmerScrollleiste;
  std::vector<MenuEintrag*> mEintraege;
  std::vector<int> mEintraegeY;  /* relativ zu mY0.
				    Geht eins weiter als mEintraege,
				    so daß es auch die Gesamthöhe enthält. */
  BlattMenu * mObermenu;    /* NULL für das Hauptmenü */
  
  /* Wenn der Eintrag, wo dies ein Untermenü ist, erfahren möchte, wenn
     das Menü verlassen wird, sollte er sich mit setObereintrag() hier
     eintragen. */
  MenuEintragSubmenu * mObereintrag;

  /* Wenn was Hyperaktiv ist, kann mWahl trotzdem ein anderer Menüpunkt
     sein: wenn sich die Maus über einem anderen Menüpunkt befindet.
     (Tastendrücke gehen dann aber an den hyperaktiven Eintrag) */
  MausBereich mWahl;
  /* True, wenn Button unten; wird (im Moment) nur für Scrollleistenpfeile
     gebraucht. */
  bool mPress;
  int mHyperaktiv;  // eintrag_keiner wenn nix hyperaktiv ist
  Str mInfoText;
  int mInfoW;       // negativ für "kein Scrollen", sonst Textbreite
  int mInfoX;       /* current position of scrolling info text.
		       Can be negative. In fact, the scrolling text is drawn
		       twice: This is the left copy, the right one starts
		       at mInfox+mInfoW. */

  /* mX0 = x-Koordinate fürs alignen... getrennt nach 
     mY0 = y-Koordinate vom oberen Rand von Menüpunkt 0
     (evtl. weit oberhalb vom Bildschirm) */
  int mX0[zl_anzahl], mY0, mZeigVon, mZeigBis;
  /* mAnimXX: Wie ohne Anim, aber tatsächliche Position während einer
     Scroll-Animation (im Gegensatz zu: Zielposition) */
  int mAnimY0, mAnimZeigVon, mAnimZeigBis;
  /* Aktuelle Scrollgeschwindigkeit */
  int mScrollGesch;
  
  bool mRahmenUpdaten;
  bool mRaenderUpdaten;
  bool mInfozeileUpdaten;
  
 public:
  explicit BlattMenu(bool immerscrollleiste = false);
  virtual ~BlattMenu();
  /* Gleich nach dem Konstruktor aufrufen, wenn das Obermenu nicht NULL
     sein soll. Schoener waers, obermenu direkt dem Konstruktor zu
     uebergeben. Das wuerde aber bedeuten, dass man gezwungen ist, in
     *jeder* Klasse, die von BlattMenu erbt, einen Konstruktor zu
     schreiben. Liefert einfach this zurueck, damit man 
       (new BlattMenuXXX())->setObermenu(...)
     schreiben kann */
  BlattMenu * setObermenu(BlattMenu * obermenu);
  void setObereintrag(MenuEintragSubmenu * obereintrag);

  void neuerEintrag(MenuEintrag*);

  virtual void oeffnen(bool durchMaus, int wahl = eintrag_keiner);
  virtual void keyEvent(const SDL_keysym & taste);
  virtual void mouseButtonEvent(bool press, int x, int y);
  virtual void mouseMotionEvent(bool press, int x, int y, int x_alt, int y_alt);
  virtual void resizeEvent();
  virtual void anzeigen();
  virtual void zeitSchritt();

 protected:  
  virtual void doEscape();
  virtual void doReturn(bool durchMaus);
    
  void menuLoeschen();

  /* Ändert mWahl und kümmert sich drum, dass Graphik geupdatet wird */
  void setWahl(MausBereich wahl);
  void setWahl(int eintrag, int subBereich = subbereich_default);
 
  /* Ändert mHyperaktiv und kümmert sich drum, dass Graphik geupdatet wird */
  void setHyperaktiv(int ha);

  /* Kümmert sich um mInfotext und mInfoY.
     Wird aufgerufen, wenn sich mInfotext vielleicht ändern soll.
     Also unter anderem von setWahl() und setHyperaktiv() */
  void updateInfo();

  /* Teilt dem Eintrag seinen neuen Subbereich mit. Der Eintrag kümmert
     sich dann um sein Graphik-Update */
  void updateEintrag(int e);
  
  void sichtbaresUpdaten();
 
  bool istScrollbar() const;

  void scrollleisteScroll(int sgn);
 
  /* Gleicht mY0, mZeigVon und mZeigBis an mWahl an.
     sprung = true => keine Animation, sondern direkt dort hin. */  
  void setScrollZielHigh(yneuwahl = ynw_mitte, bool sprung = false);
  
  /* Setzt mY0 und gleicht mZeigVon und mZeigBis an.
     sprung = true => keine Animation, sondern direkt dort hin. */  
  void setScrollZielLow(int neuy, bool sprung = false);
  
  void scrollZeitSchritt();
  
  /* Berechnet zeigVon und zeigBis aus Y0... mit oder ohne anim */
  void calcZeigVonBis(int y0, int & von, int & bis);
  
 private:
  void navigiere(int d, int vorschlag = -1);
  
  MausBereich getMausPos(int x, int y);
  
  /* Wo befindet sich der Cursor aus Sicht von Tastatur-Usern? */
  int getTastenCursorPos();
};




class BlattStartAt: public BlattMenu {

 public:
  BlattStartAt(): BlattMenu(true) {}  /* true: Scrollleiste immer da... und esc-Button */
 
  virtual void oeffnen(bool durchMaus, int wahl = eintrag_keiner);
    /* Hier wird der int ignoriert, da sich die Klasse selbst drum kümmert */
 protected:
  virtual void doReturn(bool durchMaus);
};





class BlattHauptmenu: public BlattMenu {

 public:
  BlattHauptmenu();
};



class BlattPrefs: public BlattMenu {

 public:
  BlattPrefs();
  
 protected:
  virtual void doEscape();
};






#endif
