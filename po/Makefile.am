# po/Makefile.am for cuyo by Mark Weyer in 2009
# Modified 2011 by the cuyo developers
# Maintenance modifications 2010,2011,2014 by the cuyo developers
# This file is based on the following:
# # po/Makefile.am for LPRng by Bernhard R. Link in 2007
# # this file is based on gettext-0.14.4' Makefile.in.in which states:
# # # Makefile for PO directory in any package using GNU gettext.
# # # Copyright (C) 1995-1997, 2000-2005 by Ulrich Drepper <drepper@gnu.ai.mit.edu>
#
# This file can be copied and used freely without restrictions.  It can
# be used in projects which are not available under the GNU General Public
# License but which still want to provide support for the GNU gettext
# functionality.
# Please note that the actual code of GNU gettext is covered by the GNU
# General Public License and is *not* in the public domain.


LINGUAS = de pt

DOMAIN = $(PACKAGE)
POFILES = $(patsubst %,$(srcdir)/%.po,$(LINGUAS))
GMOFILES = $(patsubst %,$(srcdir)/%.gmo,$(LINGUAS))
MSGMERGE_UPDATE = @MSGMERGE@ --update

MAINTAINERCLEANFILES = Makefile.in $(GMOFILES) *.mo $(DOMAIN).pot
EXTRA_DIST = pot.sed cual2fakec $(DOMAIN).pot $(POFILES) $(GMOFILES)


# We would rather use ../data/used_levels instead of ../data/*.ld
# However, that would require that the definition of pot_sources
# has a dependency on ../data/used_levels, which is something make
# does not support.
pot_sources = $(shell ls ../src/*.cpp ../src/*.cc ../src/*.h) $(shell ls ../data/*.ld)



all: all-@USE_NLS@
all-yes: $(DOMAIN).pot $(POFILES) $(GMOFILES)
all-no:

install-data-local: install-data-local-@USE_NLS@
install-data-local-no: all
install-data-local-yes: all
	$(mkinstalldirs) $(DESTDIR)$(datadir)
	for lang in $(LINGUAS) ; do \
		cat=$$lang.gmo \
		dir=$(localedir)/$$lang/LC_MESSAGES; \
		$(mkinstalldirs) $(DESTDIR)$$dir; \
		if test -r $$cat; then realcat=$$cat; else realcat=$(srcdir)/$$cat; fi; \
	  	echo "installing $$realcat as $(DESTDIR)$$dir/$(DOMAIN).mo"; \
		$(INSTALL_DATA) $$realcat $(DESTDIR)$$dir/$(DOMAIN).mo; \
	done

uninstall-local: uninstall-local-@USE_NLS@
uninstall-local-no:
uninstall-local-yes:
	for lang in $(LINGUAS) ; do \
		rm -f $(DESTDIR)$(localedir)/$$lang/LC_MESSAGES/$(DOMAIN).mo; \
	done



# By virtue of this rule, this Makefile probably only works with srcdir=.
$(DOMAIN).pot: $(pot_sources) pot.sed
	rm -rf data
	mkdir data
	cd ../data && make used_levels
	for ldfile in $$(cat ../data/used_levels) ; do \
	  ./cual2fakec ../data/$$ldfile > data/$$ldfile ; \
	done
	rm -rf src
	mkdir src
	cp ../src/*.cpp ../src/*.cc ../src/*.h src
	xgettext \
	    --from-code=ISO-8859-1 \
	    --language=C++ \
	    --keyword=_ \
	    --keyword=N_ \
	    --add-comments=TRANSLATORS \
	    --msgid-bugs-address=cuyo-devel@nongnu.org \
	    -o - \
	    src/* data/* \
	  | sed -f pot.sed > cuyo.pot


%.mo: %.po
	$(MSGFMT) -c -o t-$*.mo $*.po && mv t-$*.mo $*.mo

%.gmo: %.po
	lang=`echo $* | sed -e 's,.*/,,'`; \
	cd $(srcdir) && rm -f $${lang}.gmo && $(GMSGFMT) -c --statistics -o t-$${lang}.gmo $${lang}.po && mv t-$${lang}.gmo $${lang}.gmo

# This target rebuilds a PO file if $(DOMAIN).pot has changed.
# Contrary to how others handle this, the PO file is always touched.
%.po: $(srcdir)/$(DOMAIN).pot
	lang=`echo $@ | sed -e 's,.*/,,' -e 's/\.po$$//'`; \
	if test -f "$(srcdir)/$${lang}.po"; then \
	  cd $(srcdir) && $(MSGMERGE_UPDATE) $${lang}.po $(DOMAIN).pot; \
	  touch $${lang}.po; \
	else \
	  $(MAKE) $${lang}.po-create; \
	fi

# General rule for creating PO files.
%.po-create:
	@lang=`echo $@ | sed -e 's/\.po-create$$//'`; \
	echo "File $$lang.po does not exist. If you are a translator, you can create it through 'msginit'." 1>&2; \
	exit 1

update-po: Makefile
	$(MAKE) $(DOMAIN).pot-update
	$(MAKE) $(POFILES)
	$(MAKE) $(GMOFILES)

