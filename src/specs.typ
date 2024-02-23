
#import "template.typ": *
#show: Document.with(
  title: [C-Block Language Specifications]
)


= Brief introduction to the C-Block Language.

== The "Hello World!" of the C-Block Language.
The simplest example of any programming language syntax is its _Hello World!_ example. We'll follow the example & do it too. To recreate the _Hello World!_ program, create a file `*/main.cb` that contains the next source code:

```
#include <std1_20_4.ch>
@(load) foo::hello_world() {
  MINECRAFT::SAY("Hello World!");
}
```

When compiled, the output datapack will have the next files:

1. A function located at `data/foo/functions/hello_world.mcfunction` that contains:```hs
say "Hello World!"
```

2. A function tag located at `data/minecraft/tags/functions/load.mcfunction` that contains:```json
{
  "values": [
    "foo:hello_world"
  ]
}
```

3. A pack declaration file located at `pack.mcmeta` that contains:```json
{
  "pack":{
    "pack_format": 0,
    "description": "none"
  }
}
```

Take notice that the pack declaration uses a pack_format 0 & has set the datapack description to `"none"`. Thus, there's missing lines of code to complete the example.

Let's add 2 new lines of code to complete the example:```
#pack_format 26
#pack_description "Hello World"

#include <1_20_4.ch>

@(load) foo::hello_world() {
  MINECRAFT::SAY("Hello World!");
}
```

The 2 extra lines added at the top of the file are used to declare pack meta data, they must be added in the main Command Source file & any use of them on any other command source file will lead to an explicit abort.

Now the output datapack will have the next files:
1. A function located at `data/foo/functions/hello_world.mcfunction` that contains:```hs
say "Hello World!"
```

2. A function tag located at `data/minecraft/tags/functions/load.mcfunction` that contains:```json
{
  "values": [
    "foo:hello_world"
  ]
}
```

3. A pack declaration file located at `pack.mcmeta` that contains:```json
{
  "pack":{
    "pack_format": 26,
    "description": "Hello World"
  }
}
```



= Logic functions & Command source files.
As shown in the previous chapter, logic functions consist of 4 parts: the directives of the function, the function name, the function parameters & , which will be explained in detail in this chapter.

== Function directives:
They are directives to specify how a certain logic function should behave on parsing & compilation --& if the directive is parented, it will also affect the children of the function--. They always start with an at symbol, following a couple of parenthesis with the directive name & the value of it. E. g:```
/*
 *
 *  Set the directive "log" to true, which is used to
 *  tell the compiler that it should add logs that
 *  are sent to chat, to the function foo::bar & its
 *  children functions
 *
 */

@(log=true) foo::bar() ...
```

In the _C-Block Standard CB-I_, there are 3 function directives, which are: // Note: in next push, add runtime-handling directive
 - _*`load` directive:*_ [Sweetener; Not parented; accepts a bool value; default: false] if set to `true`, the function will be added to the function tag `#minecraft:load`.
 - _*`tick` directive:*_ [Sweetener; Not parented; accepts a bool value; default: false] if set to `true`, the function will be added to the function tag `#minecraft:load`.
 - _*`log` directive:*_ [Parented; accepts a bool value or string value] if set to `true`, the function will contain extra `tellraw` log commands; if set if set a string, the function will contain extra `tellraw` log commands which will be sent only to players which have a tag that matches the string; if set to `false`, the function will not contain `tellraw` log commands, if the parent function has this directive set to true, it will override it for its own body & its children functions.

// NOTE: in next push, add the missing parts

= Command functions & Command header files.
Command headers are one of the key structure of the C-Block Language to allow high modularity & configurability, as they act as the intermediate between the abstracted logic of c-block files & the compiled datapack. These files are declared using the file extension `.ch` (acronym of "Command Header")

Command headers define the string output of a specific command (with the exception of `execute` and `data` due their complexity), take these 2 examples from the _Standard Command Header_ for the version 1.20.4:

1. Definition of the command `say`:```
// say <message>
MINECRAFT::SAY(
  auto msg           // <message> //
) {
  cmdLine(
    "say"               +  " "  +
    msg                 // END //
  )
}
```
The first great difference between logic functions --which compile into `mcfunction` files-- & command functions is the CAPITALISATION on the function names, this is used to difference which functions should be treated as command functions & thus follow command function parsing. Take note that it uses `auto` data type, thus it should accept any data type as parameter (including macros). \ 

2. Definition of the command `summon`:```
//  summon <entity>
MINECRAFT::SUMMON(
  string entity       // <entity> //
) {
  cmdLine(
    "summon"            +  " "  +
    entity              // END //
  )
}```Which is followed by its respective overloads #footnote([Only command functions are allowed to have overloads following _C-Block Standard CB-I_; private logic function overloading will be standarised in the CB-II standard.]):```
//  OVERRIDE: summon <entity> <vec3>
MINECRAFT::SUMMON(
  string entity,      // <entity> //
  auto pos[3]          // <vec3> //
) {
  cmdLine(
    "summon"            +  " "  +
    entity              +  " "  +
    pos[0]              +  " "  +
    pos[1]              +  " "  +
    pos[2]              // END //
  );
}
//  OVERRIDE: summon <entity> <x> <y> <z>
MINECRAFT::SUMMON(
  string entity,      // <entity> //
  auto x,               // <x> //
  auto z,               // <y> //
  auto z                // <z> //
) {
  cmdLine(
    "summon"            +  " "  +
    entity              +  " "  +
    x                   +  " "  +
    y                   +  " "  +
    z                   // END //
  );
}
//  OVERRIDE: summon <entity> <vec3> <entity_nbt>
MINECRAFT::SUMMON(
  string entity,      // <entity> //
  auto pos[3],         // <vec3> //
  nbt entity_nbt    // <entity_nbt> //
) {
  if (NBTmatch_Path(entity_nbt, {}) == false) {
    throwFatal("Entity NBT must be a compound.");
  }
  cmdLine(
    "summon"            +  " "  +
    entity              +  " "  +
    pos[0]              +  " "  +
    pos[1]              +  " "  +
    pos[2]              +  " "  +
    entity_nbt          // END //
  );
}
//  OVERRIDE: summon <entity> <x> <y> <z> <entity_nbt>
MINECRAFT::SUMMON(
  string entity,      // <entity> //
  auto x,               // <x> //
  auto y,               // <y> //
  auto z,               // <z> //
  nbt entity_nbt    // <entity_nbt> //
) {
  if (entity_nbt.isCompound == false) {
    throwFatal("Entity NBT must be a compound.");
  }
  cmdOut(
    "summon"            +  " "  +
    entity              +  " "  +
    x                   +  " "  +
    y                   +  " "  +
    z                   +  " "  +
    entity_nbt          // END //
  );
}
```

It is allowed the next operations related:
- _Modify the Standard Command Header:_ as the Standard Command Header remains as an independent header from the compiler, it is alloed to modify the Standard Header itself to change the name, parameters & output of standard command functions.
- _Create a custom command header:_ it can include overrides & overloads to command functions of the Standard Command Header aswell new custom command functions #footnote([This can be useful to create pseudo-APIs to incorporate external functions of data pack libraries that do not follow macro parameters natively.]).
- _Create or override Command Functions on Command Source files:_ it is allowed to create command function on Command Source files, E. g:```
#include <std1_20_4.ch>

// override MINECRAFT:SUMMON
@override MINECRAFT:SUMMON (auto message) {
  cmdOut(
    "say"               +  " "  +
    message             // END //
  )
}
```

