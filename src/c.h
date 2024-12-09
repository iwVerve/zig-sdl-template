#ifdef __EMSCRIPTEN__
    #import "emscripten.h"
    #import "SDL/SDL.h"
    #import "SDL/SDL_image.h"
    #import "SDL/SDL_mixer.h"
#else
    #import "SDL.h"
    #import "SDL_image.h"
    #import "SDL_mixer.h"
#endif
