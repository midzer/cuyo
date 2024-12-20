/*
   Copyright <=2001 by Immanuel Halupczok
   Modified 2001,2002,2006,2011 by the cuyo developers

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef INKOMPATIBEL_H
#define INKOMPATIBEL_H

/* Sollte immer das erste sein, was included wird (falls irgendwelche
   bools oder so definiert werden). */
#include <config.h>



#ifndef HAVE_LIBZ
#define HAVE_LIBZ 0
#endif


#ifdef WIN32
/* Ob das folgende die beste Lösung für Windows ist, weiß ich nicht.
   Aber es ist eine. */s
#ifndef PKGDATADIR
#define PKGDATADIR (PACKAGE"-"VERSION"\\data")
#endif

/* Windows: Default hat kein getopt */
#ifndef HAVE_GETOPT
#define HAVE_GETOPT 0
#endif

#else
/* Nicht Windows: Default hat getopt */
#ifndef HAVE_GETOPT
#define HAVE_GETOPT 1
#endif

#endif



#endif

