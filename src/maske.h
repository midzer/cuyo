/*
   Copyright 2011 by Mark Weyer

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

#ifndef MASKE_H
#define MASKE_H

#include <SDL.h>

struct RohMaske {
  friend class Maske;
public:
  RohMaske();
  RohMaske(const RohMaske &);
  ~RohMaske();

  void init(int w, int h);
  void set_pixel(int x, int y, bool);
  void fill(bool);
  bool is_empty() const;

private:
  int mWidth,mHeight;
  bool * mData;
};

struct Maske {
public:
  Maske();
  Maske(const Maske &);
  ~Maske();

  void scale(const RohMaske & src, int scale);
  bool is_empty() const;
  void masked_blit(SDL_Surface * src, int srcx, int srcy,
		   SDL_Rect & mask,
		   SDL_Surface * dst, SDL_Rect & dstr) const;
    /* Assumes that src and dst have the same format. */

private:
  int mWidth,mHeight;
  Sint8 * mData;
    /* Positive entries indicate the presense of the mask, negative entries
       its absence. The absolute value of an entry minus one says that so
       many further entries in the same line (to the right) have the same sign.
    */
};

#endif

