/***************************************************************************
                          fehler.h  -  description
                             -------------------
    begin                : Fri Jul 21 2000
    copyright            : (C) 2000 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2001,2002,2006,2008,2010,2011,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef FEHLER_H
#define FEHLER_H

#include <cstdarg>

#include "stringzeug.h"
#include "cuyointl.h"



/** Fehler, der gethrowt werden kann. Macht beim Erzeugen gleich ein
    bisschen Aufräumarbeiten: Blop::abbruchGleichzeitig() wird aufgerufen. */
class Fehler {
  friend Fehler iFehler(const char * fmt, ...);

  /** Erzeugt einen Fehler, bei dem der Text noch nicht gesetzt ist.
      Ist nur für iFehler() gedacht. */
  Fehler();

public:
  Fehler(Str text);

  Fehler(const char * fmt, ...)
#ifdef __GNUC__
    __attribute__ ((format (printf, 2, 3)))
#endif
    ;

  /** Liefert true, wenn dieser Fehler gerne eine Log-Datei schicken würde,
      d. h. wenn es ein interner Fehler ist oder - bei nicht internen
      Fehlern - wenn _keine_ ld-Datei an Cuyo übergeben wurde. */
  bool getSendLog() const;

  /** True, wenn ggf. "please send log" angehängt werden soll. GGf heißt:
      Wenn getSendLog() true liefert. */
  Str getText(bool mitLog = false) const;
  
  void setText(const Str & t);
  
private:
  /** True bei internen Fehlern (d. h. bei Fehlern, die auf jeden Fall
      an mich gemailt werden sollen.) */
  bool mIntern;
  
  /** Die Fehlermeldung */
  Str mText;
  
public:
  /** True, wenn es schon einen Code gab, der gesagt hat, wo der Fehler
      passiert ist. (Damit so was nicht zweimal gesagt wird.) */
  bool mMitZeile;
};


/** Erzeugt einen internen Fehler. */
Fehler iFehler(const char * fmt, ...)
#ifdef __GNUC__
  __attribute__ ((format (printf, 1, 2)))
#endif
  ;




/* Self-explanatory... */
#define send_log_string \
  "Please send the log-file \"cuyo.log\" to cuyo@karimmi.de"



/* PBEGIN_TRY und PEND_TRY() werden in scanner.ll und parser.yy verwendet.
   Sie fangen Fehler ab und geben sie aus, damit
   weitergeparst werden kann und mehrere Fehler gleichzeitig ausgegeben
   werden können. (P = Parse) */

#define PBEGIN_TRY try {
#define PEND_TRY(on_error) } catch (Fehler fe) {\
  print_to_stderr(_sprintf("%s:%d: %s\n", gDateiName.data(), gZeilenNr, \
			   fe.getText().data()));			\
  gGabFehler = true;\
  { on_error; }\
}




/* Debug-Macro: Zählt, wie oft es aufgerufen wird. Gibt nach schritte
   vielen Malen den neuen Wert und string aus. */
#define D_ZAEHLEN(schritte, string) do { \
  static int _zzz = 0;\
  if (_zzz++ % schritte == 0) print_to_stderr(_sprintf(string" %d\n", _zzz)); \
} while (0)


/* Damit ich nicht aus versehen das falsche ASSERT verwende...: */
#undef ASSERT

#define CASSERT(blub) do { \
  if (!(blub)) \
    throw iFehler("Internal error: \"%s\" in %s:%d", \
                  #blub, __FILE__, __LINE__); \
} while (0)


#define SDLASSERT(blub) do { \
  if (!(blub)) \
    throw iFehler("SDL error: \"%s\" in %s:%d: %s", \
                  #blub, __FILE__, __LINE__, SDL_GetError()); \
} while (0)


#endif
