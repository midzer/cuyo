/***************************************************************************
                          main.cpp  -  description
                             -------------------
    begin                : Mit Jul 12 22:54:51 MEST 2000
    copyright            : (C) 2000 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

Modified 2001,2002,2006-2008,2010,2011,2014 by the cuyo developers

 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include "inkompatibel.h"
#include "stringzeug.h"

#include <cstdlib>
#include <cstdio>
#include <ctime>

#if HAVE_GETOPT
/* Laut man-page muss man <unistd.h> includen, wenn man getopt() verwenden
   will. Laut gcc <getopt.h>. gcc sitzt am längeren Hebel... */
//#include <unistd.h>
#include <getopt.h>
#endif

#include "cuyointl.h"
#include "fehler.h"

#include "global.h"

#include "config.h"

#include "ui.h"
#include "ui2cuyo.h"
#include "version.h"


void hilfe() {
  /* TRANSLATORS: "cuyo" is a program's name,
     "-f", "-g", and "-h" are options' names,
     "ld" is a file suffix. None of these should be translated. */
  print_to_stderr(_(""
    "usage: cuyo [-g <width>x<height>] [-h] [-f] [ld-file]\n"
    "  -g <width>x<height>  set window size\n"
    "  -f   fullscreen mode\n"
    "  -h   print this help message\n"
    "(More options are documented in the man page.)\n"
    ));
}


void aufrufFehler() {

  hilfe();

  exit(1);
}


#if !HAVE_GETOPT
/* selbstprogrammiertes getopt()... funkioniert sehr eingeschränkt. */


#error Version without getopt has never been tested

int optind = 1;
char * optarg;

char getopt(int argc, char * const argv[], const char * optstring) {
  if (optind < argc && argv[optind][0] == '-') {
    char c = argv[optind++][1];
    const char * o = optstring;
    while (*o) {
      char os = *o++;
      if (os != ':' && c == os) {
        if (*o == ':') {  /* Does the option require an argument? */
	  if (argv[optind-1][2] != 0) {
	    /* Argument without space, e.g. -d1 */
	    optarg = &argv[optind-1][2];
	  } else if (optind >= argc) {
            print_to_stderr(_sprintf(_("Argument to -%c missing\n"), c));
            return '?';
	  } else {
	    /* Argument with space, e.g. -d 1 */
	    optarg = argv[optind++];
	  }
	}
        return c;
      }
    }
    print_to_stderr(_sprintf(_("Unknown option '%c'\n"), c));
    return '?';
  } else
    return -1;
}


#endif



typedef void optionsVerwalter(char *);

/* Eingabe ist eine ,-getrennte Liste von Versionsmerkmalen. */
void scanVersion(char * liste) {
  Cuyo::mKommandoZeilenVersion = Version();
  while (*liste!=0) {
    char* ende;
    /* Suche das Ende des aktuellen Merkmals. */
    for (ende=liste; *ende!=0 && *ende!=','; ende++) {}
    /* leere Merkmale werden unterdrückt */
    if (liste==ende)  /* Da *liste!=0, wissen wir jetzt *ende=','. */
      liste++;
    else {
      if (*ende==0) {
	Cuyo::mKommandoZeilenVersion.nochEinMerkmal(liste);
	liste=ende;
      }
      else {
	*ende = 0;
	Cuyo::mKommandoZeilenVersion.nochEinMerkmal(liste);
	liste=ende+1;
      }
    }
  }
}

/* Sucht, ob in den Optionen irgendwo --name=wert oder --name wert steht,
   ruft dann verwalter(wert) auf und löscht diesen Teil aus den Optionen. */
void scanWertOption(int &argc, char *argv[], const char * name,
		    optionsVerwalter* verwalter) {
  for (int i=1; i<argc; i++) {
    int j;
    for (j=0; (name[j]==0 ? 0 : argv[i][j]==name[j]); j++) {}
    if (name[j]==0) {  /* Gefunden! (vielleicht) */
      if (argv[i][j]==0 && i+1<argc) {  /* Gefunden in der Form --name wert */
        (*verwalter)(argv[i+1]);
        argc-=2;
        for (j=i; j<argc; j++)
          argv[j]=argv[j+2];
        return;
      }
      if (argv[i][j]=='=') {          /* Gefunden in der Form --name=wert */
        (*verwalter)(argv[i]+j+1);
        argc-=1;
        for (j=i; j<argc; j++)
          argv[j]=argv[j+1];
        return;
      }
    }
  }
}


void scanOptionen(int argc, char *argv[]) {
  int opt_chr;

  /* Erst mal defaults setzen */
  gDebug = false;
  //gKlein = false;
  gDateiUebergeben = false;


  /* Zuerst nach ---Optionen suchen (genauer: "--"-Optionen),
     damit das im Zweifelsfall eigene getopt() nicht durcheinander kommt.
     Die gefundenen Optionen werden gelöscht. */

  Cuyo::mKommandoZeilenVersion = Version();
  scanWertOption(argc,argv,"--version",&scanVersion);


  /* Jetzt die --Optionen. */

  while ((opt_chr = getopt(argc, argv, "dhg:f")) != -1) {
    switch (opt_chr) {
      case 'd':
        gDebug = true;
	break;
//       case 's':
//         //gKlein = true;
// 	break;
      case 'h':
        hilfe();
        exit(0);
      case 'g': {
          int w, h;
          if (sscanf(optarg, "%dx%d", &w, &h) != 2) {
	    print_to_stderr(_("Could not parse option -g\n"));
            aufrufFehler();
	  }
	  UI::setGeometry(w, h);
	}
	break;
      case 'f':
        SDLTools::setFullscreen(true);
	break;
      case '?':
        aufrufFehler();
	break;
      default:
        throw Fehler("%s","Internal error during parsing of options");
    }
  }

  /* Ist da noch ein Argument übrig? Dann ist das die übergebene
     ld-Datei. */
  if (optind < argc) {
    gDateiUebergeben = true;
    gLevelDatei = argv[optind++];
  }
  
  /* Immer noch Argumente übrig? Das ist ein Fehler */
  if (optind < argc) {
    print_to_stderr(_sprintf(_("%s: Too many arguments\n"), argv[0]));
    aufrufFehler();
  }


}





int main(int argc, char *argv[])
{

  init_NLS();

  try {

    Version::init();
    
    /* Der Pfaditerator braucht unser 0tes Argument, um in lokalen
       Verzeichnissen nach den Daten-Dateien zu suchen. */
    gCuyoPfad = nimmPfad(argv[0]);
    
    /* Ist das hier noch nötig, da es im Moment vor jedem Level-Start
       einzeln aufgerufen wird? Egal. */
    srand(time(0));
    
    scanOptionen(argc, argv);
        
    UI::init();

    UI::run();
    
    UI::destroy();
    
    return 0;

  } catch (Fehler f) {
    print_to_stderr(_sprintf("Error: %s\n", f.getText().data()));
    return 1;
  }
  
}
