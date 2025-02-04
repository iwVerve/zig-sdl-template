# Zig SDL Template

Zig version: 0.14.0-dev.3020+c104e8644

## Features
- Asset loading.
- Wasm compilation with emscripten.
- SDL and Emscripten as dependencies of the build system.

## Code hotreloading

## Todo
- Code hotreloading.
- Asset hotreloading.
- Documentation.

## Compiling
```bash
zig build run # Debug build
zig build run -Dstatic -Doptimize=ReleaseFast # Release build
zig build run -Dtarget=wasm32-emscripten # Web build
```

## References
- https://github.com/samhattangady/hotreload
- https://github.com/silbinarywolf/sdl-zig-demo-emscripten
