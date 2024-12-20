/***************************************************************************
                          cuyointl.h  -  description
                             -------------------
    begin                : Wed Jul 4 2001
    copyright            : (C) 2001 by Immi
    email                : cuyo@karimmi.de

Modified 2001,2008-2011 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef CUYOINTL_H
#define CUYOINTL_H

#include <config.h>
#include <cstdlib>

#ifdef ENABLE_NLS

  const char * our_gettext(const char *);
    /** Works like gettext, except that it does not try to translate "".
        The output charset is our internal charset.
	It is suitable for printf format strings. */

  #include <libintl.h>
  #define _(String) our_gettext (String)
  #define N_(String) (String)

#else

  #define _(String) (String)
  #define N_(String) (String)

#endif


void init_NLS();

char * convert_for_font(const char *);
char * convert_for_stdout(const char *, size_t &);
char * convert_for_window_title(const char *);
  /** Convert a string from the internal charset to some other charset.
      They are just copies in case ENABLE_NLS is not defined.

      In any case, the caller receives the responsibility for freeing the
      returned string.

      The extra argument for the stdout variant is for returning the length
      of the output string (without the terminating 0). This is needed
      because the string may contain non-terminating 0s. */

#endif

