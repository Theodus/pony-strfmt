/*
fmt := '{' [arg] [':' spec] '}'
arg := USize
spec := [align] [sign] [alt] [width] [prec] [type]
align := [U8] ('<' | '^' | '>')
sign := ('+' | '-' | ' ')
alt := '#'
width := USize
prec := '.' USize
type := ('b' | 'd' | 'f' | 'o' | 'x' | 'X')
*/

use "debug"

class _Format
  let _spec: String box
  let _arg: Stringable box
  var _offset: USize = 0
  var _default: USize = 0

  var _align: _Align = _AlignLeft
  var _align_fill: U8 = ' '
  var _padding: USize = 0
  var _pre: String = ""
  var _width: USize = -1
  var _prec: USize = 0

  new create(spec: String box, arg: Stringable box) =>
    _spec = spec
    _arg = arg

  fun ref apply(): String iso^ ? =>
    let out = recover String end
    Debug.out("\n"+_spec)
    Debug.out(_arg)
    parse_align()
    out

  // [U8] ('<' | '^' | '>')
  fun ref parse_align() ? =>
    parse_sign()

  // ('+' | '-' | ' ')
  fun ref parse_sign() ? =>
    parse_alt()

  // '#'
  fun ref parse_alt() ? =>
    parse_width()

  // USize
  fun ref parse_width() ? =>
    parse_prec()

  // '.' USize
  fun ref parse_prec() ? =>
    parse_type()

  // ('b' | 'd' | 'f' | 'o' | 'x' | 'X')
  fun ref parse_type() ? =>
    error

primitive _AlignLeft
primitive _AlignRight
primitive _AlignCenter
type _Align is ( _AlignLeft | _AlignCenter | _AlignRight)
