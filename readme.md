# Dretro-core

This is a [libretro](https://www.libretro.com/index.php/api/) [core](https://docs.libretro.com/development/cores/developing-cores/) implementation. Keep in mind thats my first take on writing
a libretro core and my first time using [dlang](https://dlang.org/).

At the moment this is a minimal implementation (a [skeletor](https://github.com/libretro/skeletor) port), it simply draw a background and a rectangle.

## Usage

Make sure to have dlang and dub installed and available into your path.

Build the core using dub:

```sh
dub
```

Run [retroach](https://www.retroarch.com/) (of course if should run with any [https://docs.libretro.com/development/frontends/](libretro front), but that's the one i'am using):

```sh
path/to/retroarch -v -L path/to/this/repo/lib/libdretro-core.{dylib,so}
```

`-v` option is optional i use it to debug my core since it makes retroarch verbose.

## Steps

- Translating [libretro.h](https://raw.githubusercontent.com/libretro/libretro-common/master/include/libretro.h) to dlang using [dstep](https://code.dlang.org/packages/dstep) and fixing manually some errors (trying to compile the `libretro.d` file)
- Print a rectangle (Handle the frame buffer and draw a AA rectangle to it)

## Next steps

- Handle input
- Minimal game scene (moving square)

## Very uncertain next steps

- Handle audio
- Include [mruby](https://mruby.org/) so you can script your core in ruby
- Build a pico8 like platform
