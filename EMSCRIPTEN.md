# Emscripten

## Build

```
./autogen.sh
emconfigure ./configure --datadir=./data
emmake make
```

## Link

```
em++ -O3 -flto src/*.o -o index.html -sUSE_SDL=2 -sUSE_SDL_IMAGE=2 -sUSE_SDL_MIXER=2 -sSDL2_MIXER_FORMATS='["wav","mod"]' -sUSE_ZLIB=1 -sASYNCIFY -sASYNCIFY_IGNORE_INDIRECT -sASYNCIFY_ONLY=@funcs.txt -sINITIAL_HEAP=32mb -sENVIRONMENT=web --preload-file data/ --closure 1 -sEXPORTED_RUNTIME_METHODS=['allocate']
```
