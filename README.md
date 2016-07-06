# pony-fmt

based on Python's [.format()](https://pyformat.info/#simple) and Rust's [std::fmt](https://doc.rust-lang.org/std/fmt/)

The grammar for the syntax is as follows:
```
fmt := '{' [arg] [':' spec] '}'
arg := USize
spec := [[fill]align] [sign] [alt] [width] [prec] [type]
fill := U8
align := ('<' | '^' | '>')
sign := ('+' | '-' | ' ')
alt := '#'
width := USize
prec := '.' USize
type := ('b' | 'd' | 'f' | 'o' | 'x' | 'X')
```

The `{` and `}` characters can be escaped by doubling, i.e. `{{` becomes `{` and `}}` becomes `}`.

Example use:
```pony
Fmt("Hello")
// "Hello"

Fmt("{{Hello}}")
// "{Hello}"

Fmt("Hello, {}!", ["world"])
// "Hello, world!"

Fmt("{}, {}, {0}, {}", ["0", "1", "2"])
// "0, 1, 0, 2"

Fmt("{:<10}", ["left"])
// "left      "

Fmt("{:>10}", ["right"])
// "     right"

Fmt("{:^10}", ["center"])
// "  center  "

Fmt("{0:d} {0:x} {0:X} {0:o} {0:b}", [USize(42)])
// "42 2a 2A 52 101010"

Fmt("{0:#x} {0:#o} {0:#b}", [USize(42)])
// "0x2a 0o52 0b101010"

Fmt("{:.2}", [F64(1.234567)])
// "1.23"

Fmt("{:+f}, {:+f}", [F64(3.14), F64(-3.14)])
// "+3.1400, -3.1400"

Fmt("{: f}, {: f}", [F64(3.14), F64(-3.14)])
// " 3.1400, -3.1400"

Fmt("{:-f}, {:-f}", [F64(3.14), F64(-3.14)])
// "3.1400, -3.1400"
```
