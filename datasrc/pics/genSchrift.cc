/*
   Copyright 2006 by Immanuel Halupczok

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

#include <cstdlib>
#include <cstdio>
#include <cmath>
#include <cstring>
#include <cerrno>

#include <SDL.h>
#include <SDL_image.h>




#define dst_buch_gr 24
#define src_buch_gr 160
#define buch_vergroesserung 0.8
#define schwarzer_rand 0  // (Alt: 4) in src-Bild-Pixeln
int radius;
#define radius_font 5  // (Alt: 7) der 3d-Striche, in src-Bild-Pixeln
#define radius_titel 21

#define alpha_threshold 50 //Alt: 85

#define testbild_gr (2 * ges_radius + 10)



#define ges_radius (radius + schwarzer_rand)
#define meinMax 200.0

/* von x,y,z wird nur die Richtung, nicht die Länge verwendet */
#define licht_x (-0.6)
#define licht_y (-1.3)
#define licht_z (0.7)

#define licht_diffus 1.1
#define licht_glanz 0.5
#define glanz_winkel_1 (M_PI / 10)
#define glanz_winkel_2 (M_PI / 5)
#define licht_streu (0.5)







#define SDLASSERT(_) if (!(_)) { fprintf(stderr, "%s\n", SDL_GetError()); SDL_Quit(); }


#define FORXY for (int x = 0; x < dst->w; x++) for (int y = 0; y < dst->h; y++)
#define FORYX for (int y = 0; y < dst->h; y++) for (int x = 0; x < dst->w; x++)
#define FORXYP for (int x = 0; \
            fprintf(stderr, "."), x < dst->w || (fprintf(stderr, "\n"), 0); \
            x++) \
          for (int y = 0; y < dst->h; y++)





/* A 32-Bit-surface, to copy the pixel format from */
SDL_Surface * gSampleSurface32 = 0;




/* Converts a surface to a 32-bit-surface with alpha. The original surface
   is deleted. */  
void convertSurface32(SDL_Surface *& s) {
  /* Silly: The only way I know to create a SDL_PixelFormat is using
     SDL_CreateRGBSurface; so we need a "sample surface" to get the
     format from... */
  SDL_Surface * tmp = SDL_ConvertSurface(s, gSampleSurface32->format, SDL_SWSURFACE);
  SDLASSERT(tmp);
  SDL_FreeSurface(s);
  s = tmp;
}





/* Creates a 32-bit-surface with alpha. After filling it with your
   data, you should convert it to screen format */
SDL_Surface * createSurface32(int w, int h) {

  union { Uint32 f; Uint8 k[4];} rmask, gmask, bmask, amask;
  
  /* Die richtigen Bits der Masken auf 1 setzen; das Problem ist, dass
     welches die richtigen Bits sind von der Enianness abhaengen.
     Das folgende macht's richtig: */
  rmask.f = gmask.f = bmask.f = amask.f = 0;
  rmask.k[0] = gmask.k[1] = bmask.k[2] = amask.k[3] = 0xff;

  SDL_Surface * s = SDL_CreateRGBSurface(SDL_HWSURFACE, w, h, 32, rmask.f, gmask.f, bmask.f, amask.f);
  SDLASSERT(s);
  return s;
}





void initSDL() {

  /* Initialize the SDL library */
  SDLASSERT(SDL_Init(SDL_INIT_VIDEO) == 0);
  
  /* Clean up on exit */
  atexit(SDL_Quit);

  /* Set the name of the window (and the icon) */
  SDL_WM_SetCaption("bearb", "Bearb");
  
  /* Initialize the display
     requesting a software surface
     BitsPerPixel = 0: Take the current BitsPerPixel
     SDL_ANYFORMAT: Other pixel depths are ok, too. */
  //SDL_Surface * screen = SDL_SetVideoMode(100, 100, 0,
  //		 SDL_SWSURFACE/*|SDL_DOUBLEBUF*/|SDL_ANYFORMAT);
  //SDLASSERT(screen);

  gSampleSurface32 = createSurface32(1, 1);
  SDLASSERT(gSampleSurface32);
}



/*************************************************************************/


union Pix {
  Uint32 sdl;
  struct {
    Uint8 r, g, b, a;
  } f;
};


bool operator ==(Pix a, Pix b) {
  return a.sdl == b.sdl;
}


Pix Pixel(Uint8 r, Uint8 g, Uint8 b, Uint8 a = 255) {
  Pix ret;
  ret.f.r = r; ret.f.g = g; ret.f.b = b; ret.f.a = a;
  return ret;
}




/* Return a reference to the pixel at (x, y);
   assumes that the surface is 32-Bit.
   NOTE: The surface must be locked before calling this! */
Pix & getLPixel(SDL_Surface *surface, int x, int y) {
  int bpp = surface->format->BytesPerPixel;
  return *(Pix *) ((Uint8 *)surface->pixels + y * surface->pitch + x * bpp);
}


Pix gPixelDefault = Pixel(255, 255, 255);


Pix getPixel(SDL_Surface *surface, int x, int y) {
  if (x < 0 || y < 0 || x >= surface->w || y >= surface->h)
    return gPixelDefault;
  else
    return getLPixel(surface, x, y);
}





/*************************************************************************/



SDL_Surface * bi;

SDL_Surface * src, * dst;

void beginSchritt(int nw = bi->w, int nh = bi->h) {
  src = bi;
  dst = createSurface32(nw, nh);
  SDL_LockSurface(src);
  SDL_LockSurface(dst);
}

void endSchritt() {
  SDL_UnlockSurface(src);
  SDL_UnlockSurface(dst);
  SDL_FreeSurface(src);
  bi = dst;
}



void striche_reparieren() {
  beginSchritt();
  
  FORXY {
    bool p0 = getPixel(src, x, y).f.r == 0;
    bool p1 = getPixel(src, x+1, y).f.r == 0;
    bool p2 = getPixel(src, x, y+1).f.r == 0;
    bool p3 = getPixel(src, x-1, y).f.r == 0;
    bool p4 = getPixel(src, x, y-1).f.r == 0;
    int nach = p1+p2+p3+p4;

    bool erg = p0 || nach >= 3;

    getLPixel(dst, x, y) = erg ? Pixel(0, 0, 0) : Pixel(255, 255, 255);
  }
  
  endSchritt();
}



void genTestbild() {
  src = dst = bi = createSurface32(testbild_gr, testbild_gr);
  SDL_LockSurface(bi);
  FORXY {
    getLPixel(bi, x, y) = Pixel(255, 255, 255);
  }
  getLPixel(bi, testbild_gr/2, testbild_gr/2) = Pixel(0, 0, 0);
  SDL_UnlockSurface(bi);
}




void malKreis(int xm, int ym) {
  for (int x = -ges_radius; x <= ges_radius; x++) if (x + xm >= 0 && x + xm < dst->w)
    for (int y = -ges_radius; y <= ges_radius; y++) if (y + ym >= 0 && y + ym < dst->h) {
      double r = sqrt(x * x + y * y);
      if (r < ges_radius) {
        Pix alt = getPixel(dst, x + xm, y + ym);
        Uint8 neur = (Uint8) (r / ges_radius * meinMax);
        if (neur < alt.f.r) {
          getLPixel(dst, x + xm, y + ym) =
                 Pixel(neur, (Uint8) ((x * 1.0 / ges_radius + 1) * meinMax / 2),
                             (Uint8) ((y * 1.0 / ges_radius + 1) * meinMax / 2));
        }
      }
    }
}


double norm(double & x, double & y, double & z) {
  return sqrt(x*x+y*y+z*z);
}

void normieren(double & x, double & y, double & z) {
  double n = norm(x, y, z);
  x /= n; y /= n; z /= n;
}




void drei_d() {
  beginSchritt();
  
  FORXY getLPixel(dst, x, y) = Pixel(255, 0, 0);
  
  fprintf(stderr, "Kreise\n"); 
  FORXYP {
    if (getPixel(src, x, y).f.r == 0) {
      malKreis(x, y);
    }
  }
  
  double lx = licht_x, ly = licht_y, lz = licht_z;
  normieren(lx, ly, lz);
  double gx = lx, gy = ly, gz = lz + 1;
  normieren(gx, gy, gz);
  
  lx *= licht_diffus; ly *= licht_diffus; lz *= licht_diffus;
  
  double glanz_cos_1 = cos(glanz_winkel_1);
  double glanz_cos_2 = cos(glanz_winkel_2);
  
  fprintf(stderr, "Faerbung\n"); 
  FORXYP {
    Pix & p = getLPixel(dst, x, y);
    if (p.f.r == 255) {
      p = Pixel(0, 0, 0, 0);
      /*
      if (((x / 160) & 1) == ((y / 160) & 1))
        p = Pixel(230, 230, 230);
      else
        p = Pixel(255, 255, 255);
      */
    } else {
      double r = p.f.r / meinMax / radius * ges_radius;
      if (r >= 1) {
        p = Pixel(0, 0, 0);
      } else {
        double xx = p.f.g / meinMax * 2 - 1;
        double yy = p.f.b / meinMax * 2 - 1;
        double zz = sqrt(1 - r * r);

        double ldiffus = xx * lx + yy * ly + zz * lz;
        if (ldiffus < 0) ldiffus = 0;

        double lglanz = xx * gx + yy * gy + zz * gz;
        if (lglanz < glanz_cos_2)
          lglanz = 0;
        else if (lglanz > glanz_cos_1)
          lglanz = 1;
        else
          lglanz = (lglanz - glanz_cos_2) / (glanz_cos_1 - glanz_cos_2);
        lglanz *= licht_glanz;

        double l = ldiffus + licht_streu + lglanz;
        int lint = (int) (l * 255);
        if (lint < 0) lint = 0;
        if (lint > 2*255) lint = 2*255;

        Uint8 rot = lint > 255 ? 255 : lint;
        Uint8 gruenblau = lint < 255 ? 0 : lint - 255;
        p = Pixel(rot, gruenblau, gruenblau);
      }
    }
  }
  
  endSchritt();
}


double buchSkal(int d) {
  double rand = (1 - buch_vergroesserung) / 2;
  return ((d * 1.0 / dst_buch_gr) * buch_vergroesserung + rand) * src_buch_gr;
}


void skalieren() {
  gPixelDefault = Pixel(0, 0, 0, 0);

  beginSchritt(dst_buch_gr * 16, dst_buch_gr * 16);
  
  fprintf(stderr, "Skalieren\n"); 
  FORXYP {
    int buch = x / dst_buch_gr + 16 * (y / dst_buch_gr);
    double sx0 = src_buch_gr * (buch % 8) + buchSkal(x % dst_buch_gr);
    double sy0 = src_buch_gr * (buch / 8) + buchSkal(y % dst_buch_gr);
    double sx1 = src_buch_gr * (buch % 8) + buchSkal(x % dst_buch_gr + 1);
    double sy1 = src_buch_gr * (buch / 8) + buchSkal(y % dst_buch_gr + 1);
    
    double ges_r = 0, ges_g = 0, ges_b = 0, ges_a = 0, ges_pix = 0;
    for (int xx = (int) floor(sx0); xx <= (int) ceil(sx1) - 1; xx++) {
      double x_ant = 1;
      if (xx < sx0) x_ant = xx + 1 - sx0;
      if (xx + 1 > sx1) x_ant = sx1 - xx;
      for (int yy = (int) floor(sy0); yy <= (int) ceil(sy1) - 1; yy++) {
        double y_ant = 1;
        if (yy < sy0) y_ant = yy + 1 - sy0;
        if (yy + 1 > sy1) y_ant = sy1 - yy;
        
        double ant = x_ant * y_ant;
        ges_pix += ant;
        
        Pix p = getPixel(src, xx, yy);
        double aa = ant * p.f.a / 255;
        ges_r += aa * p.f.r / 255;
        ges_g += aa * p.f.g / 255;
        ges_b += aa * p.f.b / 255;
        ges_a += aa;
      }
    }
    if (ges_a < 0.001) {
      getLPixel(dst, x, y) = Pixel(0, 0, 0, 0);
    } else {
      ges_r /= ges_a;
      ges_g /= ges_a;
      ges_b /= ges_a;
      ges_a /= ges_pix;
      getLPixel(dst, x, y) = 
            Pixel((Uint8) (ges_r * 255),
                  (Uint8) (ges_g * 255),
                  (Uint8) (ges_b * 255),
                  (Uint8) (ges_a * 255));
    }
    
  }
  
  endSchritt();
}



void alpha_abrunden() {
  beginSchritt();
  
  fprintf(stderr, "Alpha abrunden\n");
  
  FORXYP {
    bool p0 = getPixel(src, x, y).f.a > alpha_threshold;
    bool p1 = getPixel(src, x+1, y).f.a > alpha_threshold;
    bool p2 = getPixel(src, x, y+1).f.a > alpha_threshold;
    bool p3 = getPixel(src, x-1, y).f.a > alpha_threshold;
    bool p4 = getPixel(src, x, y-1).f.a > alpha_threshold;
    int nachbarn = p1+p2+p3+p4;

    /* Bei Alpha = 0 nicht auf true setzen; da würde die Farbe vom
       Pixel gar nicht stimmen */
    if (nachbarn >= 3 && getPixel(src, x, y).f.a >= 1) p0 = true;
    if (nachbarn <= 1) p0 = false;
    
    Pix & erg = getLPixel(dst, x, y);
    erg = getPixel(src, x, y);
    erg.f.a = p0 ? 255 : 0;
  }
  
  endSchritt();
}


void karieren() {
  beginSchritt();

  fprintf(stderr, "Karieren\n");
  
  FORXYP {
    int ka = (x / dst_buch_gr + y / dst_buch_gr) & 1;
    ka = ka * 80 + 140;
    Pix p = getPixel(src, x, y);
    if (p.f.a == 0)
      p = Pixel(ka, ka, ka);
    getLPixel(dst, x, y) = p;
  }

  endSchritt();
}


/* Wir brauchen den blau-Kanal nicht; da kann der Alpha-Kanal rein */
void praeConvert() {
  beginSchritt();

  fprintf(stderr, "praeConvert\n");
  
  FORXYP {
    Pix p = getPixel(src, x, y);
    p.f.b = p.f.a; p.f.a = 255;
    getLPixel(dst, x, y) = p;
  }

  endSchritt();
}



void ausgeben(const char * dateiname) {
  FILE * datei = fopen(dateiname,"wb");
  if (datei==NULL) {
    fprintf(stderr, "Error %d attempting to open %s for writing.",
	    errno, dateiname);
    exit(errno);
  }

  fprintf(datei,
	  "P7\nWIDTH %d\nHEIGHT %d\nDEPTH 4\nMAXVAL 255\nENDHDR\n",
	  dst->w, dst->h);

  FORYX {
    Pix p = getPixel(bi,x,y);
    fprintf(datei, "%c%c%c%c", p.f.r, p.f.g, p.f.b, p.f.a);
  }
}




int main(int c, char ** v) {

  bool font = c >= 2 && strcmp(v[1], "-font") == 0;
  
  if (font) {
    v++; c--;
  }

  if (c != 3) {
    fprintf(stderr, "Usage: %s [-font] <src-file.png> <dst-file.pam>\n", v[0]);
    fprintf(stderr, "   Or: %s -test <dst-file.pam>\n", v[0]);
    exit(1);
  }

  initSDL();
  
  if (font) radius = radius_font; else radius = radius_titel;

  bool testen = strcmp(v[1], "-test") == 0;
  if (testen) {
    fprintf(stderr, "Testbild generieren\n");
    genTestbild();
  } else {
    fprintf(stderr, "laden\n");
    bi = IMG_Load(v[1]);
    SDLASSERT(bi);
  }
  
  fprintf(stderr, "->32bit\n");
  convertSurface32(bi);
  
  drei_d();
  
  if (!testen) {
    if (font)
      skalieren();
    alpha_abrunden();
    //karieren();
    //praeConvert();
  } else {
    karieren();
  }
  
  fprintf(stderr, "speichern\n");
  ausgeben(v[2]);
  
  fprintf(stderr, "ende\n");

  SDL_Quit();
  return 0;
}
