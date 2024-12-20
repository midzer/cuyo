/***************************************************************************
                        stringzeug.h  -  description
                             -------------------
    begin                : Mon Mar 20 2006
    copyright            : (C) 2006 by Mark Weyer
    email                : cuyo-devel@nongnu.org

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

#ifndef STRINGZEUG_H
#define STRINGZEUG_H

#include <config.h>
#include <cstdarg>
#include <string>




struct Str {
  friend Str operator + (const Str &, const Str &);
  friend Str operator + (const Str &, const char *);
  friend Str operator + (const Str &, char);
  friend Str operator + (char, const Str &);

private:

  std::string inhalt;

  Str(const std::string &);

public:

  Str();
  Str(const char *);
  Str(const Str &);

  bool isEmpty() const;
  int length() const;
  char operator [] (int) const;
  char & operator [] (int);
  const char * data() const;

  Str left(int) const;
  Str mid(int, int) const;
  Str right(int) const;

  void operator += (char);
  void operator += (const Str &);

  bool operator == (const Str &) const;
  bool operator < (const Str &) const;
  bool operator != (const Str &) const;
  bool operator != (const char *) const;

};


Str operator + (const Str &, const Str &);
Str operator + (const Str &, const char *);
Str operator + (const Str &, char);
Str operator + (char, const Str &);

Str _sprintf(const char * format, ...)
#ifdef __GNUC__
  __attribute__ ((format (printf, 1, 2)))
#endif
  ;

Str _vsprintf(const char * format, va_list ap);

void print_to_stderr(const Str &);

#endif

