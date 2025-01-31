#ifdef __EMSCRIPTEN__
    #import "emscripten.h"
    #import "SDL2/SDL.h"
    #import "SDL2/SDL_image.h"
    #import "SDL2/SDL_mixer.h"
    #import "SDL2/SDL_ttf.h"
#else
    #import "SDL.h"
    #import "SDL_image.h"
    #import "SDL_mixer.h"
    #import "SDL_ttf.h"
#endif
