/* A Bison parser, made by GNU Bison 2.5.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2011 Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     IF_PREC = 258,
     ELSE_TOK = 259,
     OR_TOK = 260,
     AND_TOK = 261,
     LE_TOK = 262,
     GE_TOK = 263,
     NE_TOK = 264,
     EQ_TOK = 265,
     BIS_TOK = 266,
     BITUNSET_ATOK = 267,
     BITSET_ATOK = 268,
     NEG_PREC = 269,
     INCLUDE_TOK = 270,
     BEGIN_CODE_TOK = 271,
     END_CODE_TOK = 272,
     SWITCH_TOK = 273,
     IF_TOK = 274,
     VAR_TOK = 275,
     BUSY_TOK = 276,
     ADD_TOK = 277,
     SUB_TOK = 278,
     MUL_TOK = 279,
     DIV_TOK = 280,
     MOD_TOK = 281,
     BITSET_TOK = 282,
     BITUNSET_TOK = 283,
     RND_TOK = 284,
     GGT_TOK = 285,
     BONUS_TOK = 286,
     MESSAGE_TOK = 287,
     SOUND_TOK = 288,
     EXPLODE_TOK = 289,
     VERLIER_TOK = 290,
     DEFAULT_TOK = 291,
     DA_KIND_TOK = 292,
     FREMD_TOK = 293,
     REINWORT_TOK = 294,
     WORT_TOK = 295,
     NACHBAR8_TOK = 296,
     NACHBAR6_TOK = 297,
     NULLEINS_TOK = 298,
     ZAHL_TOK = 299,
     HALBZAHL_TOK = 300,
     BUCHSTABE_TOK = 301,
     PFEIL_TOK = 302
   };
#endif
/* Tokens.  */
#define IF_PREC 258
#define ELSE_TOK 259
#define OR_TOK 260
#define AND_TOK 261
#define LE_TOK 262
#define GE_TOK 263
#define NE_TOK 264
#define EQ_TOK 265
#define BIS_TOK 266
#define BITUNSET_ATOK 267
#define BITSET_ATOK 268
#define NEG_PREC 269
#define INCLUDE_TOK 270
#define BEGIN_CODE_TOK 271
#define END_CODE_TOK 272
#define SWITCH_TOK 273
#define IF_TOK 274
#define VAR_TOK 275
#define BUSY_TOK 276
#define ADD_TOK 277
#define SUB_TOK 278
#define MUL_TOK 279
#define DIV_TOK 280
#define MOD_TOK 281
#define BITSET_TOK 282
#define BITUNSET_TOK 283
#define RND_TOK 284
#define GGT_TOK 285
#define BONUS_TOK 286
#define MESSAGE_TOK 287
#define SOUND_TOK 288
#define EXPLODE_TOK 289
#define VERLIER_TOK 290
#define DEFAULT_TOK 291
#define DA_KIND_TOK 292
#define FREMD_TOK 293
#define REINWORT_TOK 294
#define WORT_TOK 295
#define NACHBAR8_TOK 296
#define NACHBAR6_TOK 297
#define NULLEINS_TOK 298
#define ZAHL_TOK 299
#define HALBZAHL_TOK 300
#define BUCHSTABE_TOK 301
#define PFEIL_TOK 302




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 2068 of yacc.c  */
#line 116 "parser.yy"

  Code * code;
  Code * codepaar[2];
  Str * str;
  int zahl;
  int zahlpaar[2];
  Knoten * knoten;
  DefKnoten * defknoten;
  ListenKnoten * listenknoten;
  WortKnoten * wortknoten;
  Variable * variable;
  Ort * ort;
  Version * version;
  CodeArt codeart;
  OrtHaelfte haelfte;



/* Line 2068 of yacc.c  */
#line 163 "parser.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif




