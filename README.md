# Zig SDL Template

Zig version: 0.14.0-dev.3020+c104e8644

## Features
- Asset loading.
- Wasm compilation with emscripten.
- SDL and Emscripten as dependencies of the build system.

## Code hotreloading
Run `zig build reload` to rebuild the game dll, then press F3 to reload it manually. Key can be changed in config.zig.

## Todo
- Code hotreloading.
- Asset hotreloading.
- Input handling - controller supports, rebinds.
- Saved data mananagement.
- Documentation.

## Compiling
```bash
zig build run # Debug build
zig build reload # Build dll only for hotreloading
zig build run -Dstatic -Doptimize=ReleaseFast # Release build
zig build run -Dtarget=wasm32-emscripten # Web build
```

## References
- https://github.com/samhattangady/hotreload
- https://github.com/silbinarywolf/sdl-zig-demo-emscripten
