/***************************************************************************
                          sdltools.h  -  description
                             -------------------
    begin                : Fri Jul 21 2006
    copyright            : (C) 2006 by Immi
    email                : cuyo@pcpool.mathematik.uni-freiburg.de

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

#ifndef SDLTOOLS_H
#define SDLTOOLS_H

#include <SDL.h>

#include <maske.h>

#define scale_base 4

class Str;


struct Color {
  Uint8 mR, mG, mB;
  
  Color() {}
  Color(Uint8 r, Uint8 g, Uint8 b): mR(r), mG(g), mB(b) {}
  
  /* Convert to SDL pixel value */
  Uint32 getPixel(SDL_PixelFormat *fmt = SDL_GetVideoSurface()->format) const {
    return SDL_MapRGB(fmt, mR, mG, mB);
  }
  
  Uint8 & operator[](int i) {return i == 0 ? mR : (i == 1 ? mG : mB); }
  Uint8 operator[](int i) const {return i == 0 ? mR : (i == 1 ? mG : mB); }
};




namespace SDLTools {

  /* opt_w, opt_h: size of window, as given by command line option;
     or -1,-1 to automatically choose window size */
  void initSDL(int opt_w, int opt_h);

  /* Call while cuyo is already running is not yet supported
     (but not difficult to implement) */
  void setFullscreen(bool fs);
  
  /* Change the size of the window from the view of the cuyo program.
     Does *not* change the real window size; instead, scaling may
     change.
     I propose that this should only be used in such a way that when
     the real window size is the preferred one (L_preferred_xxx),
     then scaling should never change.
     Note that changing the scaling always takes some time.
  */
  void setVirtualWindowSize(int w, int h);

  void setMainTitle();
  void setLevelTitle(const Str & levelname);

  /* Convert Qt-Key into SDL-Key; don't use Qt constants: we don't want to
     depend on Qt just to be able to read old .cuyo files. */
  SDLKey qtKey2sdlKey(int qtk);


  SDL_Rect rect(int x, int y, int w = 0, int h = 0);

  bool intersection(const SDL_Rect & a, const SDL_Rect & b, SDL_Rect & ret);


  /* Creates a 32-bit-surface with alpha. After filling it with your
     data, you should convert it to screen format */
  SDL_Surface * createSurface32(int w, int h);
  
  /* Converts a surface to a 32-bit-surface with alpha. The original surface
     is deleted. */  
  void convertSurface32(SDL_Surface *& s);
  
  /* Return a reference to the pixel at (x, y);
     assumes that the surface is 32-Bit.
     NOTE: The surface must be locked before calling this! */
  Uint32 & getPixel32(SDL_Surface *surface, int x, int y);

  /* Converts the surface to a format suitable for fast blitting onto the
     display surface. Contrary to SDL_DisplayFormat, transparency is
     respected, at least where it is full transparency. Contrary to
     SDL_DisplayFormatAlpha, it uses ColourKey for paletted surfaces.
     The source surface is assumed to be 32-Bit. */
  SDL_Surface * maskedDisplayFormat(SDL_Surface *);

  SDL_Surface * createMaskedDisplaySurface(int w, int h);

  /* Scales the surface according to our window size;
     s must be 32 bit.
     Warning: It is possible that a new surface is created and
     returned, but is is also possible that just a pointer to s
     is returned. */
  SDL_Surface * scaleSurface(SDL_Surface * s);
  
  int getScale();

  /* Like SDL_PollEvent, but the event is already scaled.
     And for resize events, the window and scaling is already
     prepared. */
  bool pollEvent(SDL_Event & evt);
}


/**
  An area is a sub-rectangle of a surface. All drawing commands
  take place inside the active area.
  Calls to enter() (enter a sub-area) can be nested.
  (This has not been tested yet.)
  Right now,
  - The surface is always the screen surface
  - There exists only one global Area
  
  Right now, all calls to methods of Area (except init and destroy)
  are expected to happen in subroutines of UI::allesAnzeigen()
*/
namespace Area {
  void destroy();

  void enter(SDL_Rect r);
  void leave();
  
  void setClip(SDL_Rect r);
  void noClip();

  void setBackground(const SDL_Rect &, SDL_Surface *);
    /** Setting the background happens relative to the current area.
        It defines the behaviour of subsequent calls to ...
        leave()ing the current area unsets the background. */
  void maskBackground(const Maske *, SDL_Rect, int x, int y);
    /* Copies the background through the mask to the screen.
       The SDL_Rect is relative to the mask in unscaled coordinates.
       x and y are the destination on the screen relative to the current area.
    */

  /* If the coordinates of srcrect are not a multiple of scale_base, then
     rounding of the width and height of srcrect is done in such a way that
     the result is correct in the *destination*, not in the source. */
  void blitSurface(SDL_Surface *src, SDL_Rect srcrect, int dstx, int dsty);
  void blitSurface(SDL_Surface *src, int dstx, int dsty);
  
  void fillRect(SDL_Rect dst, const Color & c);
  void fillRect(int x, int y, int w, int h, const Color & c);

  /* Fills everything outside the current virtual window */
  void fillBorder(const Color & c);

  /* You have to call the following methods to make your drawing operations
     really visible on the screen. (However, the update will take place only
     at the next call to doUpdate) */
  void updateRect(SDL_Rect dst);
  void updateRect(int x, int y, int w, int h);
  /* Better than calling updateRect(bigRect): Stops collecting small
     rectangles. All means really all, not only active area. */
  void updateAll();
  
  /* To be called only by ui.cpp */
  void doUpdate();
}


#endif

