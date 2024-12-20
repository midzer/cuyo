#
#   Copyright 2001 by the cuyo developers
#   Modified 2002,2003,2006-2008,2014 by the cuyo developers
#   Maintenance modifications 2011 by the cuyo developers
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



# Nicht angeben, weil da kein Makefile.am drin ist. (Wird nicht benötigt, da
# die Bilder von hier aus installiert werden.)
# SUBDIRS = pics

MAINTAINERCLEANFILES = Makefile.in

# Alle .ld-Dateien, die in main.ld erwähnt werden (main.ld erwähnt sich
# selbst). Aus irgendeinem Grund wird das mehrfach ausgeführt. Wenn es
# nur um make und nicht um automake ginge, könnte man hier ?= statt :=
# verwenden und wahrscheinlich wäre alles gut. Das kann mal jemand
# beheben, der mehr von automake versteht.
leveldateien := $(shell ./used_levels.sh)
lddateien := $(leveldateien) summary.ld globals.ld example.ld

# levels gehören zur Distribution. Und die used-Skripte auch.
EXTRA_DIST = $(lddateien) used_images.sh used_sounds.sh used_levels.sh genSummary.pl summary.in

# levels in das pkgdata-Verzeichnis installieren
pkgdata_DATA = $(lddateien)



# Wenn keine Libz existiert, sollen die Bilder beim installieren entpackt
# werden:
if HASLIBZ
unzip =
else
unzip = gunzip $(DESTDIR)$(pkgdatadir)/pics/*.gz
endif


# Beim installieren (von prozessorunabhängem) außerdem die Bilder und sounds kopieren:
install-data-local:
	$(mkinstalldirs) $(DESTDIR)$(pkgdatadir)/pics
	$(INSTALL_DATA) $(srcdir)/pics/*.png $(DESTDIR)$(pkgdatadir)/pics/ || true
	$(INSTALL_DATA) $(srcdir)/pics/*.xpm $(DESTDIR)$(pkgdatadir)/pics/ || true
	$(INSTALL_DATA) $(srcdir)/pics/*.xpm.gz $(DESTDIR)$(pkgdatadir)/pics/ || true
	$(unzip)
	$(mkinstalldirs) $(DESTDIR)$(pkgdatadir)/sounds
	$(INSTALL_DATA) $(srcdir)/sounds/*.wav $(DESTDIR)$(pkgdatadir)/sounds/ || true
	$(INSTALL_DATA) $(srcdir)/sounds/*.it $(DESTDIR)$(pkgdatadir)/sounds/ || true


# Ach, was soll's: Ich geh davon aus, dass jemand, der Cuyo installiert,
# eh nur Bilder hat, die installiert werden sollen. Also braucht nicht
# extra nochmal das langsame Bild-Test-Skript gestartet zu werden. (Ansonsten
# müsste man obige Zeile durch die nachfolgende ersetzen.)
#	$(INSTALL_DATA) `cat used_images` $(DESTDIR)$(pkgdatadir)/pics/


# Die Bilder sollen auch in die Distribution: Und die Sounds auch
dist-hook: used_images used_sounds
	mkdir $(distdir)/pics
	cp -p `cat used_images` $(distdir)/pics/
	mkdir $(distdir)/sounds
	cp -p `cat used_sounds` $(distdir)/sounds/


# Ein paar spezielle Make-Regeln:

summary.ld: genSummary.pl $(leveldateien) summary.in
	perl -w genSummary.pl

used_levels: summary.ld
	echo $(leveldateien) > used_levels

# Die Bild-Dateien nicht alle einzeln aufzählen, sondern automatisch
# diejenigen nehmen, die in den levels stehen.
# Das tut das Skript used_images.sh
# Es findet übrigens auch die .xpm.gz-Bilder.
used_images: used_images.sh summary.in $(lddateien) pics
	./used_images.sh $(srcdir) '$(lddateien)' > used_images

# Entsprechend die Sounds
used_sounds: used_sounds.sh summary.in $(lddateien) sounds
	./used_sounds.sh $(srcdir) '$(lddateien)' > used_sounds

# Wenn beim Erzeugen einer Datei ein Fehler passiert, soll, falls
# trotzdem schon eine halbe Datei erzeugt wurde, diese halbe Datei
# geloescht werden. Ist fuer genSummary.pl notwendig (und sollte
# eigentlich sowieso der default sein.)	
.DELETE_ON_ERROR:


