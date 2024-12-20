/***************************************************************************
                          menueintrag.h  -  description
                             -------------------
    begin                : Mit Jul 12 22:54:51 MEST 2000
    copyright            : (C) 2006 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2006-2008,2010,2011 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef MENUEINTRAG_H
#define MENUEINTRAG_H

#include <vector>
#include <SDL.h>

#include "stringzeug.h"
#include "inkompatibel.h"

#include "blatt.h"



#define MaxDrawDinge 10




/* Malt in der Zukunft einen Teil eines Menüeintrags.
   Das Bezugssystem für Koordinaten ist AlignTop im Menüeintrag. */

struct DrawDing {
private:
  enum {
    dda_Nichts,
    dda_Text,
    dda_Icon,
    dda_Bild
  } mArt;

  Str mText;
  int mHotkey;
  Font * mFont;
  //int mDx;/* Wenn die Schrift nicht gleich bei mX0 losgehen soll */
            /* Soll sie nie. Soll immer L_menu_rand_lr dazu */
  bool mRahmen;
  int mBild;   // Index in BlattMenu::gBlattPics
  int mBildchen;
  SDL_Rect mRect;

public:
  int mBinSubBereich;
  int mX0,mX1; // mX1 ist wie immer um 1 zu groß
  int mY0,mY1;
  int mXPos;
  bool mAbschneiden;

  /* Konstruktoren, passend zur Art: */

  DrawDing() : mArt(dda_Nichts) {};
  DrawDing(const Str & text,
	   int hotkey, /* Die Position des Hotkeys in text.
                         Negative Spezialwerte siehe
                         oben in menueintrag.cpp */
	   int binSubBereich, /* Subbereich, zu dem dieses Drawding gehört */
	   int x, int y,
	   int align = AlignHCenter,   /* Akzeptiert nur waagerechtes Zeug,
					  senkrecht ist immer zentriert. */
           Font * font = NULL,  /* Default hängt von aktSubBereich ab */
	   int * xmin = NULL, int * xmax = NULL
	     /* Wenn die !=0 sind, wird dort schon mal unsere Ausdehung
		reingeschrieben. */);
  DrawDing(int bild, int bildchen, int x, int y);
  //DrawDing(int bild, int xbd, int ybd, int x, int y);
  DrawDing(int bild, int x, int y);
  
  void abschneiden(int x0, int x1);
  
  void anzeigen(int subBereich, int x, int y) const;
};




class MenuEintrag {
 
 public:
  enum Art {
    Art_normal,
    Art_aktiv,    /* Bekommt (durch doHyperaktiv) key-events,
		     wenn man drauf ist. */
    Art_hyper,    /* Bekommt (durch doHyperaktiv) key-events,
		     nachdem es angeklickt wurde. */
    Art_hyperakt, /* "Art_aktiv + Art_hyper" */
    Art_deko
  };
  const int mHoehe;  /* Ganz viel wird einfacher, wenn das hier const ist,
			also verlässt sich auch ganz viel drauf.
			Im Moment scheinen wir auch nicht mehr zu brauchen.
			Wenn sich das mal ändert, kann man sich immer noch
			die Arbeit machen, BlattMenu::anzeigen() und so
			anzupassen. */
  
 protected:
  BlattMenu * mPapi;
  Str mName;
  int mAccel;   /* Der Keycode des Hotkeys */
  int mAccIndex;
  void (*mDoReturn)();
  bool (*mGetStrom)(); /* Ein Menüpunkt, der grad keinen Strom kriegt,
                          kann auch nicht ausgewählt werden */
  Art mArt;
  int mX0, mX1;
  
  bool mUpdaten;
  int mSubBereich;

 private:
  DrawDing mDraw[MaxDrawDinge];
  int mAnzDraw;

 public:
  MenuEintrag(BlattMenu * papi, Str na = "", void(*doret)() = 0, int accel = 0,
	      int hoehe = L_menueintrag_defaulthoehe);
  MenuEintrag(BlattMenu * papi, Str na, Art ea,
	      int hoehe = L_menueintrag_defaulthoehe);
  virtual ~MenuEintrag() {}
  
  MenuEintrag * setGetStrom(bool(*getstrom)()) {mGetStrom = getstrom; return this;}
  void setNieStrom();
  void setSubBereich(int subBereich);
  /* Aufrufen, wenn sich möglicherweise der Stromstatus geändert hat */
  void updateStrom();
  void updateDrawDinge();
  void setUpdateFlag() { mUpdaten = true; }
  
  int getAccel() const { return mAccel; }
  void deactivateAccel();
  
  virtual void anzeigen(int x, int y, bool graue);
  virtual void zeitSchritt() {}
  virtual Str getInfo() {return "";}
  /* y muss nicht überprüft werden; liegt auf jeden Fall zwischen 0 und hoehe */
  virtual int getMausPos(int x, int y);

  virtual void doReturn(bool durchMaus);
  virtual void doHyperaktiv(const SDL_keysym &, int) {}
  virtual bool getStrom() const;
  
  bool getWaehlbar() const;
  bool getAktiv() const;
  bool getHyper() const;
  int getX0() const {return mX0;}
  int getX1() const {return mX1;}
  virtual ZentrierLinie getZentrierLinie() const {
    return mAccel == 0 ? zl_zentriert : zl_accel;
  }

 protected:
  void doPapiEscape();  /* Damit auch die Erben das dürfen. */
  void doPapiNavigiere(int);     /* ebenso */

  /* Das füllt DrawDinge auf, malt aber nicht selbst.
     Wird auch aufgerufen, um die Breite des Menüpunkts zu bestimmen */
  virtual void updateDDIntern();

  inline DrawDing & neuDraw() {
    CASSERT(mAnzDraw+1<MaxDrawDinge);
    return mDraw[mAnzDraw++];
  }
};


class MenuEintragBild: public MenuEintrag {
  int mBildNr;
  int mXOffset;
public:
  MenuEintragBild(BlattMenu * papi, int nr);
protected:
  virtual void updateDDIntern();
};


class MenuEintragEscape: public MenuEintrag {
public:
  MenuEintragEscape(BlattMenu * papi);

  virtual void doReturn(bool durchMaus);
};



class MenuEintragSubmenu: public MenuEintrag {
 protected:
  BlattMenu * mSub;
public:
  MenuEintragSubmenu(BlattMenu * papi, const Str &, BlattMenu *, int accel=0,
		     int hoehe = L_menueintrag_defaulthoehe);
  virtual ~MenuEintragSubmenu();

  virtual void doReturn(bool durchMaus);
  virtual void doUntermenuSchliessen() {}
};



/* Könnte man Schönfinkeln, wäre diese Klasse fast unnötig... */
class MenuEintragAuswahl: public MenuEintrag {
protected:
  int mArg;
  Str mInfo;
  void (*mDoReturnInt) (int);
public:
  MenuEintragAuswahl(BlattMenu * papi, const Str & na, const Str & info,
		     void(*doretint)(int), int arg, int accel=0);
  virtual Str getInfo() {return mInfo;}
  virtual void doReturn(bool durchMaus);
};



class MenuEintragAuswahlmenu: public MenuEintragSubmenu {
  const std::vector<Str> *const mAuswahlen;
  int (*mGetAktuell) ();
  void (*mEintragDoReturn) (int);
  int mVorlauf;  // Wie viele Einträge hat das Menü vor dem "ersten"?
  int mPfeil1X0, mPfeil1X1, mPfeil2X0, mPfeil2X1;
  int mAnimation;
  int mAnimationDX;
  Str mAnimationWahlAlt;
public:
  MenuEintragAuswahlmenu(BlattMenu * papi,
			 const Str & name,
			 const std::vector<Str> *const auswahlen,
			 const std::vector<Str> *const infos,
			 int (*getakt) (), void (*doret)(int),
			 const Str & info = Str(),
			 int accel=0);

  virtual Str getInfo();
  virtual void doHyperaktiv(const SDL_keysym &, int);
  virtual int getMausPos(int x, int y);
  virtual void zeitSchritt();
  virtual void doReturn(bool durchMaus);
  virtual void doUntermenuSchliessen();
protected:
  virtual void updateDDIntern();
private:
  void doPfeil(int d);
  int schiebAktuell(int d);
};



class MenuEintragSpielerModus: public MenuEintrag {

  void (*mDoWechsel) ();
  int mModus;
  int mAnimation;
  
 public:
  MenuEintragSpielerModus(BlattMenu * papi, Str na, void(*dowechs)(), int mo):
        MenuEintrag(papi,na), mDoWechsel(dowechs), mModus(mo), mAnimation(7) {}

  virtual void zeitSchritt();
  virtual void doReturn(bool durchMaus);
 protected:
  virtual void updateDDIntern();
};



class MenuEintragTaste: public MenuEintrag {
 public:
  int mSpieler, mTaste;
 
  MenuEintragTaste(BlattMenu * papi, Str na, int sp, int ta):
      MenuEintrag(papi, na, Art_hyper), mSpieler(sp), mTaste(ta) {}

  virtual Str getInfo();
  virtual void doHyperaktiv(const SDL_keysym & taste, int);
  virtual ZentrierLinie getZentrierLinie() const { return zl_daten; }
 protected:
  virtual void updateDDIntern();
};



class MenuEintragAI: public MenuEintrag {

  int mPfeil1X0, mPfeil1X1, mPfeil2X0, mPfeil2X1;
 public:
 
  MenuEintragAI(BlattMenu * papi, Str na):
      MenuEintrag(papi, na, Art_aktiv) {}

  virtual int getMausPos(int x, int y);
  virtual void doHyperaktiv(const SDL_keysym & taste, int);
  virtual void doReturn(bool durchMaus);
  virtual void doPfeil(int d);
  virtual ZentrierLinie getZentrierLinie() const { return zl_daten; }
 protected:
  virtual void updateDDIntern();
};



class MenuEintragSound: public MenuEintrag {

  bool mBitteWarten;
  
 public:
 
  MenuEintragSound(BlattMenu * papi, Str na):
      MenuEintrag(papi, na, Art_aktiv), mBitteWarten(false) {}

  virtual void doReturn(bool durchMaus);
  virtual void doHyperaktiv(const SDL_keysym & taste, int);
  virtual ZentrierLinie getZentrierLinie() const { return zl_daten; }
 protected:
  virtual void updateDDIntern();
  
  void setSound(bool neu);
};


class MenuEintragLevel: public MenuEintrag {

  bool mGewonnen;

 public:
  MenuEintragLevel(BlattMenu * papi, Str na, bool gewonnen, bool strom);

 protected:
  virtual void updateDDIntern();
};




#endif
