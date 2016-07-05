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

  var _fill: U8 = ' '
  var _align: _Align = _AlignLeft
  var _sign: U8 = ''
  var _alt: Bool = false
  var _width: USize = 0
  var _prec: USize = 0
  var _type: U8 = 's'

  new create(spec: String box, arg: Stringable box) =>
    _spec = spec
    _arg = arg

  fun ref apply(): String iso^ ? =>
    parse_align()
    match _type
    | 's' => _format_s()
    | 'f' => _format_f()
    else
      _format_i()
    end

  // [U8] ('<' | '^' | '>')
  fun ref parse_align() ? =>
    var c = try _spec(_offset) else '' end
    match c
    | '<' =>
      _align = _AlignLeft
      _offset = _offset + 1
    | '^' =>
      _align = _AlignCenter
      _offset = _offset + 1
    | '>' =>
      _align = _AlignRight
      _offset = _offset + 1
    else
      c = try _spec(_offset+1) else '' end
      match c
      | '<' =>
        _align = _AlignLeft
        _fill = _spec(_offset)
        _offset = _offset + 2
      | '^' =>
        _align = _AlignCenter
        _fill = _spec(_offset)
        _offset = _offset + 2
      | '>' =>
        _align = _AlignRight
        _fill = _spec(_offset)
        _offset = _offset + 2
      end
    end
    parse_sign()

  // ('+' | '-' | ' ')
  fun ref parse_sign() ? =>
    let c = try _spec(_offset) else '' end
    match c
    | '+' =>
      _sign = '+'
      _offset = _offset + 1
    | '-' =>
      _sign = ''
      _offset = _offset + 1
    | ' ' =>
      _sign = ' '
      _offset = _offset + 1
    end
    parse_alt()

  // '#'
  fun ref parse_alt() ? =>
    let c = try _spec(_offset) else '' end
    match c
    | '#' =>
      _alt = true
      _offset = _offset + 1
    end
    parse_width()

  // USize
  fun ref parse_width() ? =>
    try
      (let w, let u) = _spec.read_int[USize](_offset.isize())
      if u != 0 then
        _width = w
        _offset = _offset + (u + 1)
      end
    end
    parse_prec()

  // '.' USize
  fun ref parse_prec() ? =>
    let c = try _spec(_offset) else '' end
    match c
    | '.' =>
      (let p, let u) = _spec.read_int[USize](_offset.isize()+1)
      if u != 0 then
        _prec = p
        _offset = _offset + (u + 1)
      end
    end
    parse_type()

  // ('b' | 'd' | 'f' | 'o' | 'x' | 'X')
  fun ref parse_type() ? =>
    let c = try _spec(_offset) else 's' end
    match c
    | 'b' => _type = c
    | 'd' => _type = c
    | 'f' => _type = c
    | 'o' => _type = c
    | 'x' => _type = c
    | 'X' => _type = c
    | 's' => _type = c
    else
      error
    end

  fun _format_s(): String iso^ =>
    let arg = _arg.string()
    if arg.size() < _width then
      let w = _width
      let out = recover String(w) end

      match _align
      | _AlignLeft => None
        out.append(consume arg)
        while out.size() < w do
          out.push(_fill)
        end
      | _AlignRight =>
        var i: USize = 0
        while i < (w - arg.size()) do
          out.push(_fill)
          i = i + 1
        end
        out.append(consume arg)
      | _AlignCenter =>
        let padding = _width - arg.size()
        let half = padding / 2
        var i: USize = 0
        while i < half do
          out.push(_fill)
          i = i + 1
        end
        out.append(consume arg)
        i = 0
        while i < (padding - half) do
          out.push(_fill)
          i = i + 1
        end
      end
      out
    else
      consume arg
    end

  fun _format_f(): String iso^ =>
    let out = recover String end
    out

  fun _format_i(): String iso^ =>
    let out = recover String end
    out

primitive _AlignLeft
primitive _AlignRight
primitive _AlignCenter
type _Align is ( _AlignLeft | _AlignRight | _AlignCenter)
