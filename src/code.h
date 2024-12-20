/***************************************************************************
                          code.h  -  description
                             -------------------
    begin                : Sun Jul 1 2001
    copyright            : (C) 2001 by Immi
    email                : cuyo@karimmi.de

Modified 2002,2003,2005,2006,2011 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/


#ifndef CODE_H
#define CODE_H


#include <cstdlib>
#include <cstdio>

#include "stringzeug.h"
#include "definition.h"


enum CodeArt {
  undefiniert_code,
  stapel_code,
  push_code,
  mal_code,
  mal_code_fremd,
  nop_code,
  folge_code,
  buchstabe_code,
  zahl_code,
  bedingung_code,
/* Die nachfolgenden 8 Codes sind von der Art "bla X= blub". */
  set_code,
  add_code,
  sub_code,
  mul_code,
  div_code,
  mod_code,
  bitset_code,
  bitunset_code,

  busy_code,
  bonus_code,
  message_code,
  explode_code,
  weiterleit_code,
  sound_code,
  verlier_code,

/* Ausdrucks-Codes */
  erster_acode,
  variable_acode           = erster_acode,
  zahl_acode,
  manchmal_acode,
  nachbar_acode,
  intervall_acode,
  und_acode,
  oder_acode,
  not_acode,
  rnd_acode,
  add_acode,
  sub_acode,
  mul_acode,
  div_acode,
  mod_acode,
  neg_acode,
  eq_acode,
  ne_acode,
  gt_acode,
  lt_acode,
  ge_acode,
  le_acode,
  ggt_acode,
  bitand_acode,
  bitor_acode,
  bitset_acode            = bitor_acode,
  bitunset_acode,
  bittest_acode,
  letzter_acode           = bittest_acode
};

/** Für positive b gelten a=divv(a,b)*b+modd(a,b) und 0<=modd(a,b)<b.
    Für b=0 gibt es die üblichen Fehlermeldungen.
    Für negative b gelten a=divv(a,b)*b+modd(a,b) und b<modd(a,b)<=0. */

inline int divv(int a, int b) {
  if (a<0)
    if (b<0)
      return (-a)/(-b);
    else
      return -((b-1-a)/b);
  else
    if (b<0)
      return -((a-b-1)/(-b));
    else
      return a/b;
}

inline int modd(int a, int b) {
  if (a<0)
    if (b<0)
      return -((-a)%(-b));
    else
      return a+(1+(-1-a)/b)*b;
  else
    if (b<0)
      return a-(1+(a-1)/(-b))*b;
    else
      return a%b;
}



/* Konstanten für die verschiedenen Pfeilsorten bei Entscheidungscodeen.
   Man übergebe als Zahl an den Constructor für Entscheidungscodeen
     xxx_merk_pfeil + 2 * yyy_merk_pfeil,
   wenn der Code folgendermaßen aussieht:
   {
     bla xxx> blub1;
     yyy> blub2;
   } */
#define ohne_merk_pfeil 0  // ->
#define mit_merk_pfeil 1   // =>
//#define erster_pfeil 1
//#define zweiter_pfeil 2


class Variable;
class Blop;
class DefKnoten;
class Ort;

/** Ein Cual-Code-Baum. Diese Bäume werden beim Parsen der ld-Dateien
    erzeugt und dann erst mal in Knoten abgespeichert. Wenn ein Level
    geladen wird, werden die entsprechenden Code-Pointer in die Sorten-
    Objekte gespeichert.
    Code-Objekte, die eigene interne Variablen brauchen (busy-Flag),
    reservieren sich schon bei ihrer Erzeugung die Variablen-Nummern.
    (Normale Variablen-Nummern werden allerdings von VarDefinition
    reserviert.)
*/
class Code: public Definition {

  CodeArt mArt;

  /** Nr. der Bool-Var fuer Busy-Dinge. */
  int mBool1Nr, mBool2Nr;

  /** Datei, in der dieser Code definiert wurde (für Fehlermeldungen) */
  Str mDateiName;
  /** Zeilen-Nr, in der dieser Code definiert wurde (für Fehlermeldungen) */
  int mZeilenNr;

  Code * mF1;
  Code * mF2;
  Code * mF3;
  Variable * mVar1;
  Variable * mVar2;
  int mZahl;
  int mZahl2;
  int mZahl3;
  Str mString;
  Ort * mOrt;
  
  
public:

  /* Die ganzen (normalen) Konstruktoren brauchen alle ein paar Standard-
     Parameter, die ich nicht jedes mal tippen will... */
     
#define STDPAR DefKnoten * knoten, Str datna, int znr, CodeArt art

  Code(STDPAR);
  
  Code(STDPAR, int zahl, int zahl2 = 0, int zahl3 = 0);

  Code(STDPAR, Variable * v1);

  Code(STDPAR, Variable * v1, Variable * v2);

  Code(STDPAR, Variable * v1, int zahl);

  Code(STDPAR, Code * f1, Variable * v1);
  
  Code(STDPAR, Code * f1, Code * f2 = 0, Code * f3 = 0, int zahl = 0);
  
  Code(STDPAR, Code * f1, Code * f2, Variable * v1);

  Code(STDPAR, Ort * ort, int zahl = 0);

  Code(STDPAR, Str str);
  
#undef STDPAR

  Code(DefKnoten * knoten, const Code & f, bool neueBusyNummern);
  
  
  ~Code() {
    deepLoesch();
  }
  
  /** Noch provisorisch. Am besten die print-Routinen von
      Knoten durch toString() ersetzen. */
  //void print() const { printf("%s\n", toString().data()); }
  
  
  /*Code & operator= (const Code & f) {
    deepLoesch();
    kopiere(f);
    return *this;
  }*/
  
  
  private:
  
  void deepLoesch();
  
  
  void kopiere(DefKnoten * knoten, const Code & f, bool neueBusyNummern);
  
  
  /** Liefert einen String zurück, der angibt, wo dieser Code
      definiert wurde (für Fehlermeldungen) */
  Str getDefString() const;

  public:
  

  /** Liefert zurück, wie viele Bilder dieser Code höchstens gleichzeitig
      malt. Dabei wird (im Moment) der Einfachheit halber davon ausgegangen,
      dass Ausdrücke nix malen können; dementsprechend darf getStapelHoehe()
      dafür auch nicht aufgerufen werden. nsh wird um die Anzahl der
      Nachbarstapel-Malungen erhöht. */
  int getStapelHoehe(int & nsh) const;
    


  /** Fuehrt diesen Code aus auf den Variablen von Blop b.
      In busy wird zurueckgeliefert, ob dieser Code gerade Busy ist */
  int eval(Blop & b, bool & busy) const;

  /* Dito, wenn man an-busieness nicht interessiert ist */
  int eval(Blop & b) const;


  /** Resettet den Busy-Status von diesem Baum. Ist etwas ineffizient:
      eigentlich braeuchte nicht so ein grosser Teil des Baums abgelaufen
      zu werden. Vielleicht sollte ein Code wissen, ob es unter ihm nix
      gibt mit busy-Status. */
  void busyReset(Blop & b) const;

  
};


/** Erzeugt einen Code, der prüft, ob es die
    gewünschten Nachbarn gibt (aus "01?"-String).
    Der "01?"-String kann Länge 6 oder 8 haben. */
Code * newNachbarCode(DefKnoten * knoten, Str datna, int znr,
                      Str * str);


#endif
