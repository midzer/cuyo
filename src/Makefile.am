#
#   Copyright <=2001 by the cuyo developers
#   Maintenance modifications 2002-2008,2010-2012 by the cuyo developers
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

# Verzeichnis src


## Programm cuyo erzeugen, das nach games installiert werden soll
bin_PROGRAMS = cuyo


## Die Quellen... (werden zu .o compiliert und dann gelinkt)
cuyo_SOURCES = bilddatei.cpp blopbesitzer.cpp blop.cpp blopgitter.cpp configdatei.cpp cuyointl.cpp fall.cpp cuyo.cpp kiplayer.cpp leveldaten.cpp main.cpp nachbariterator.cpp sorte.cpp spielfeld.cpp pfaditerator.cpp xpmladen.cpp parser.yy scanner.ll code.cpp knoten.cpp datendatei.cpp variable.cpp fehler.cpp definition.cpp bildstapel.cpp aufnahme.cpp punktefeld.cpp global.cpp prefsdaten.cpp sound.cpp ort.cpp ui.cpp stringzeug.cpp version.cpp font.cpp sdltools.cpp blatt.cpp menueintrag.cpp maske.cpp

## Die moc-Ergebnisse sind auch noch Sourcen. (Laut Doku muss der Inhalt der
## Variable BUILT_SOURCES auch noch in eine der anderen ?_SOURCES-Variablen.)
## Evtl. nodist_cuyo_SOURCES += ...
cuyo_SOURCES += $(BUILT_SOURCES)

## Damit auch die Header in die Distribution kommen
noinst_HEADERS = bilddatei.h blopbesitzer.h blopgitter.h blop.h configdatei.h cuyointl.h fall.h inkompatibel.h cuyo.h kiplayer.h layout.h leveldaten.h nachbariterator.h sorte.h spielfeld.h pfaditerator.h fehler.h xpmladen.h code.h knoten.h datendatei.h variable.h definition.h bildstapel.h aufnahme.h punktefeld.h global.h prefsdaten.h sound.h ort.h ui.h stringzeug.h version.h ui2cuyo.h font.h sdltools.h blatt.h menueintrag.h maske.h

## Damit der User keinen bison zu haben braucht, liefert automake
## das parser.cc automatisch mit. Aber offenbar nicht das parser.h.
noinst_HEADERS += parser.h

# Offenbar blickt das depend-dings nicht, dass scanner.ll von
# parser.h abhängt:
scanner.ll: parser.h

## Lex und Yacc...:
AM_YFLAGS = -d -v


cuyo_LDADD = $(SDL_LIBS)


## PKGDATADIR := Verzeichnis mit level.descr, etc.
## Dadurch, dass es so hier steht, kann man das
## Data-Dir zu Makezeiten noch ändern (im Gegensatz zu: steht in configure.in;
## dann ist es nach ./configure schon festgelegt).
AM_CPPFLAGS = $(SDL_CPPFLAGS) -DPKGDATADIR=\"$(pkgdatadir)\" -DLOCALEDIR=\"$(localedir)\"

## Anmerkung: Unter MACOSX wird -DPKGDATADIR ignoriert; statt dessen
## wird ARGV[0]-Pfad/../Resources verwendet


# Damit man alles unnötige Zeug löschen kann
MAINTAINERCLEANFILES = Makefile.in

CLEANFILES = parser.output

# Cuyo starten...
run: cuyo
	./cuyo -d


