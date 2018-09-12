# Mips parser/compiler written in WendyScript

Run with

```
wendy main.w cs241 test.m
```

where test.m is some text file with MIPS instructions.

That would output something like:
```
.word 0x12345678
.word 0x00430820
.word 0x00430822
.word 0x00220018
.word 0x00220019
.word 0x0022001a
.word 0x0022001b
.word 0x00000810
.word 0x00000812
.word 0x00000814
.word 0x8c411234
.word 0xac411234
.word 0x0043082a
.word 0x0043082b
.word 0x10221234
.word 0x14221234
.word 0x00200008
.word 0x00400009
```

# How it works

This is not a comprehensive compiler in that it does not do a lot of checks and
generally assumes the MIPs code inputted is rather well formed.

It simply takes a bunch of format strings and a lot of numerical conversions to
convert human readable MIPs into binary strings. The binary strings can then be
fed into another compiler (like cs241.wordasm) or reverse `xxd` to actually create
a binary.
