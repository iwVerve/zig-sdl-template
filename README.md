# Zig SDL Template

Zig version: 0.14.0-dev.2287+70ad7dcd4

## Features
- Asset loading.
- Wasm compilation with emscripten.
- SDL and Emscripten as dependencies of the build system.

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
