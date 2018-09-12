# Mips parser/compiler written in WendyScript

Run with

```
wendy main.w test.m
```

where test.m is some text file with MIPS instructions.

# How it works

This is not a comprehensive compiler in that it does not do a lot of checks and
generally assumes the MIPs code inputted is rather well formed.

It simply takes a bunch of format strings and a lot of numerical conversions to
convert human readable MIPs into binary strings. The binary strings can then be
fed into another compiler (like cs241.wordasm) or reverse `xxd` to actually create
a binary.
