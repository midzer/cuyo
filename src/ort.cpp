/***************************************************************************
                          ort.cpp  -  description
                             -------------------
    begin                : Sat Nov 26 2005
    copyright            : (C) 2005 by Mark Weyer
    email                : cuyo-devel@nongnu.org

Modified 2005-2008,2010,2011,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/



#include "blop.h"
#include "code.h"
#include "cuyo.h"
#include "fehler.h"
#include "ort.h"
#include "spielfeld.h"
#include "sound.h"



inline bool rechts_ok(bool rechts) {
  return (!rechts) || (Cuyo::getSpielerZahl()>1);
}


/** Darf finde() benutzt werden? Normalerweise werden
    Orte von reine Bildstapelblops als inkorrekt angesehen.
    mit willNurMalen = true kann das geändert werden. */
bool ort_absolut::korrekt(bool willNurMalen /*= false*/) {
  bool ret;
  switch (art) {
    case absort_feld:
      if (!rechts_ok(rechts))
	ret = false;
      else if (willNurMalen)
	ret = Cuyo::getSpielfeld(rechts)->getDatenPtr()->koordMalOK(x, y);
      else
	ret = Cuyo::getSpielfeld(rechts)->getDatenPtr()->koordOK(x, y);
      break;
    case absort_fall:
      ret = (rechts_ok(rechts) && (x==(x & 1)) && (y>=0) && (y<=1)
	     // Die Bedingung "rechts_ok(rechts)" ist Voraussetzung dafür,
	     // daß der nächste Test überhaupt gemacht werden darf.
	     ? (y>0) || (x<Cuyo::getSpielfeld(rechts)->getFallAnz()) : false);
      break;
    case absort_semiglobal:
      ret = (rechts_ok(rechts));
      break;
    case absort_global:
      ret = true;
      break;
    case absort_info:
      /* Auf Info-Blops kann man noch nicht von Cual-Code aus zugreifen. Also vermute ich, dass es ok ist,
         hier einfach false zurückzuliefern -Immi */
    case absort_nirgends:
      ret = false;
      break;
    case absort_bemalbar:
      /* absort_bemalbar ist nur ein Dummywert, der hier gar nicht auftauchen sollte. */
    default:
      throw iFehler("%s","Data corruption.");
  }
  return ret;
}


Blop & ort_absolut::finde() {
  switch (art) {
    case absort_feld:
      return Cuyo::getSpielfeld(rechts)->getDatenPtr()->getFeld(x,y);
    case absort_fall:
      return (Cuyo::getSpielfeld(rechts)->getFall(y))[x];
    case absort_semiglobal:
      return Cuyo::getSpielfeld(rechts)->getSemiglobal();
    case absort_global:
      return Blop::gGlobalBlop;
    case absort_info:
    case absort_nirgends:
      throw iFehler("%s","Internal error in ort_absolut::finde(): No ort_absolut::korrekt()");
    case absort_bemalbar:
      /* absort_bemalbar ist nur ein Dummywert, der hier gar nicht auftauchen sollte. */
    default:
      throw iFehler("%s","Data corruption.");
  }
}


/** Hat der Ort einen Platz auf dem Bildschirm? */
bool ort_absolut::bemalbar() {
  bool ret;
  switch (art) {
    case absort_feld:
    case absort_fall:
    case absort_info:
    case absort_bemalbar:
      ret = true; break;
    case absort_semiglobal:
    case absort_global:
    case absort_nirgends:
      ret = false; break;
    default:
      throw iFehler("%s","Data corruption.");
  }
  return ret;
}


Str ort_absolut::toString() const {
  Str ret;
  switch (art) {
    case absort_feld:
      ret = _sprintf("%d,%d", x,y);
      break;
    case absort_fall:
      ret = _sprintf("%d<%d>", x,y);
      break;
    case absort_info:
      ret = "?";  // Ich hab mal hier irgendwas reingeschrieben -Immi
      break;
    case absort_semiglobal:
      ret = "@@";
      break;
    case absort_global:
      ret = "@";
      break;
    case absort_nirgends:
      ret = "-";
      break;
    case absort_bemalbar:
      /* absort_bemalbar ist nur ein Dummywert, der hier gar nicht auftauchen sollte. */
    default:
      throw iFehler("%s","Data corruption.");
  }
  return ret;
}


void ort_absolut::playSample(int nr) const {
  switch (art) {
  case absort_feld:
    Sound::playSample(nr, rechts ? so_rfeld : so_lfeld,
		      2*x+1, 2*grx);
    break;
  case absort_nirgends:
    throw iFehler("%s","illegal ort for ort_absolut::playSample");
    break;
  case absort_fall:
    Sound::playSample(nr, rechts ? so_rsemi : so_lsemi);
    break;
  case absort_info:
    Sound::playSample(nr, rechts ? so_rfeld : so_lfeld,
		      rechts ? 1 : 0, 1);
    break;
  case absort_semiglobal:
    Sound::playSample(nr, rechts ? so_rsemi : so_lsemi);
    break;
  case absort_global:
    Sound::playSample(nr, so_global);
    break;
  }
}



/** ortart_hier */
Ort::Ort() :
    mArt(ortart_hier), mHaelfte(haelfte_hier),
    mXKoord(0), mYKoord(0)
{}

/** ortart_relativ_feld */
Ort::Ort(Code * x, Code * y) :
    mArt(ortart_relativ_feld), mHaelfte(haelfte_hier),
    mXKoord(x), mYKoord(y)
{}

/** ortart_relativ_fall */
Ort::Ort(Code * x) :
    mArt(ortart_relativ_fall), mHaelfte(haelfte_hier),
    mXKoord(x), mYKoord(0)
{}

/** ortart_absolut */
Ort::Ort(AbsOrtArt absart, Code * x /* = 0*/, Code * y /* = 0*/) :
    mArt(ortart_absolut), mAbsArt(absart), mHaelfte(haelfte_hier),
    mXKoord(x), mYKoord(y)
{}


Ort::Ort(DefKnoten * knoten, const Ort & f, bool neueBusyNummern) :
    mArt(f.mArt), mAbsArt(f.mAbsArt), mHaelfte(f.mHaelfte) {
  if (f.mXKoord)
    mXKoord = new Code(knoten, *f.mXKoord, neueBusyNummern);
  else
    mXKoord = 0;

  if (f.mYKoord)
    mYKoord = new Code(knoten, *f.mYKoord, neueBusyNummern);
  else
    mYKoord = 0;
}


Ort::~Ort() {
  if (mXKoord) delete mXKoord;
  if (mYKoord) delete mYKoord;
}


bool Ort::hier() {
  return mArt==ortart_hier;
}



void Ort::setzeHaelfte(OrtHaelfte haelfte) {
  mHaelfte = haelfte;
}



inline bool berechne_rechts(bool vonhieraus, OrtHaelfte haelfte) {
  bool ret;
  switch (haelfte) {
    case haelfte_hier: ret = vonhieraus; break;
    case haelfte_drueben: ret = !vonhieraus; break;
    case haelfte_links: ret = false; break;
    case haelfte_rechts: ret = true; break;
  }
  return ret;
}

ort_absolut Ort::berechne(ort_absolut vonhieraus, Blop & fuer_code) {
  switch (mArt) {
    case ortart_hier:
      return vonhieraus;
    case ortart_relativ_feld:
      CASSERT(mXKoord);
      CASSERT(mYKoord);
      if (vonhieraus.art==absort_feld) {
        int dx = mXKoord->eval(fuer_code);
        int dy = mYKoord->eval(fuer_code);

        /* Spiegeln für den Himmel-Level:
           (User will y nach unten eingeben; intern ist y nach oben.)

           Anpassung an die Hex-Koordinaten:
           Intern sind die relativen Koordinaten bei ungeradem dx
           so gespeichert, dass dy = 0 leicht schräg nach oben bedeutet.
           D. h. Für die geraden Spalten stimmt's,
           für die ungeraden muss noch verschoben werden.
           Wenn dieses Spiefeld ge-hexflipt ist, "ungerade" durch "gerade" ersetzen.
        */

        int x = vonhieraus.x + dx;
        int y = vonhieraus.y + (ld->mSpiegeln ? -dy : dy) -
	   (ld->mSechseck && (dx & 1) && ld->getHexShift(vonhieraus.rechts, vonhieraus.x));

        return ort_absolut(absort_feld,
            berechne_rechts(vonhieraus.rechts,mHaelfte),x,y);
      }
      else
	return ort_absolut(absort_nirgends);
    case ortart_relativ_fall:
      CASSERT(mXKoord);
      if (vonhieraus.art==absort_fall)
        return ort_absolut(absort_fall,
            berechne_rechts(vonhieraus.rechts,mHaelfte),
            (vonhieraus.x + mXKoord->eval(fuer_code)) & 1,
            vonhieraus.y);
      else
	return ort_absolut(absort_nirgends);
    case ortart_absolut:
      switch (mAbsArt) {
        case absort_feld:
          return ort_absolut(absort_feld,
            berechne_rechts(vonhieraus.rechts,mHaelfte),
            mXKoord->eval(fuer_code),
            mYKoord->eval(fuer_code));
        case absort_fall:
          return ort_absolut(absort_fall,
            berechne_rechts(vonhieraus.rechts,mHaelfte),
            mXKoord->eval(fuer_code) & 1,
            0);
        case absort_semiglobal:
          return ort_absolut(absort_semiglobal,
            berechne_rechts(vonhieraus.rechts,mHaelfte), 0, 0);
        case absort_global:
        case absort_nirgends:
          return ort_absolut(mAbsArt, false, 0, 0);
        default: throw iFehler(
          "Internal error in Ort::berechne(): Unknown AbsOrtArt %d",
          mAbsArt);
      }
    default:
      throw iFehler("%s","Data corruption.");
  }
}


Str Ort::toString() const {
  Str ret;
  switch (mArt) {
    case ortart_hier:
      ret = "@(0,0)";
      break;
    case ortart_relativ_feld:
      ret = "@(x,y)";
      break;
    case ortart_relativ_fall:
      ret = "@x";
      break;
    case ortart_absolut:
      switch (mAbsArt) {
        case absort_feld:
          ret = "@@(x,y)";
          break;
        case absort_fall:
          ret = "@@x";
          break;
        case absort_semiglobal:
          ret = "@@";
          break;
        case absort_global:
          ret = "@";
          break;
        case absort_nirgends:
          ret = "@@-";
          break;
        default: throw iFehler(
          "Internal error in Ort::toString(): Unknown AbsOrtArt %d",
          mAbsArt);
      }
  }
  return ret;
}

