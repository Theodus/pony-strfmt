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

class _Format
  let _spec: String box
  let _arg: (String | Number)
  var _offset: USize = 0

  var _fill: U8 = ' '
  var _align: _Align = _AlignLeft
  var _sign: U8 = '-'
  var _alt: Bool = false
  var _width: USize = 0
  var _prec: USize = 0
  var _type: U8 = 's'

  new create(spec: String box, arg: (String | Number))
  =>
    _spec = spec
    _arg = arg

  fun ref apply(): String iso^ ? =>
    parse_align()
    match _arg
    | let s: String => _format_s(s)
    | let n: I8 => _format_i(n.u128(), n < 0)
    | let n: I16 => _format_i(n.u128(), n < 0)
    | let n: I32 => _format_i(n.u128(), n < 0)
    | let n: I64 => _format_i(n.u128(), n < 0)
    | let n: I128 => _format_i(n.u128(), n < 0)
    | let n: ILong => _format_i(n.u128(), n < 0)
    | let n: ISize => _format_i(n.u128(), n < 0)
    | let n: U8 => _format_i(n.u128(), true)
    | let n: U16 => _format_i(n.u128(), true)
    | let n: U32 => _format_i(n.u128(), true)
    | let n: U64 => _format_i(n.u128(), true)
    | let n: U128 => _format_i(n.u128(), true)
    | let n: ULong => _format_i(n.u128(), true)
    | let n: USize => _format_i(n.u128(), true)
    | let n: F32 => _format_f(n.f64())
    | let n: F64 => _format_f(n)
    else
      error
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
      _sign = '-'
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
        _offset = _offset + u
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
    | 'b' => _type = 'b'
    | 'd' => _type = 'd'
    | 'f' => _type = 'f'
    | 'o' => _type = 'o'
    | 'x' => _type = 'x'
    | 'X' => _type = 'X'
    | 's' => _type = 's'
    else
      error
    end

  fun _format_s(arg: String): String iso^ =>
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
      recover
        let out = String(arg.size())
        out.append(arg)
      end
    end

  fun _format_i(x: U128, neg: Bool): String iso^ =>
    let table = match _type
    | 'X' => "0123456789ABCDEF"
    else "0123456789abcdef"
    end
    let base: U128 = match _type
    | 'b' => 2
    | 'o' => 8
    | 'x' => 16
    | 'X' => 16
    else 10
    end
    var pre = if _alt then
      match base
      | 2 => "b0"
      | 8 => "o0"
      | 16 => "x0"
      else ""
      end
    else
      ""
    end
    if not neg then pre = _sign.string() + pre end

    (let prec, let width) = (_prec, _width)
    let out = recover String((prec+1).max(width.max(31))) end

    var value = x
    if value == 0 then
      out.push('0')
    else
      while value != 0 do
        let index = ((value = value / base) - (value * base))
        try out.push(table(index.usize())) end
      end
    end
    while out.size() < _prec do
      out.push('0')
    end
    out.append(pre)
    out.reverse_in_place()

    _format_s(consume out)

  fun _format_f(x: F64): String iso^ =>
    let width = _width
    let prec = if _prec == 0 then 4 else _prec end
    let out = recover String((prec+1).max(width.max(31))) end
    if (x >= 0) and (_sign != '-') then
      out.push(_sign)
    end
    out.append(x.string())
    try
      let dec = out.substring(out.find(".")+1)
      var i = dec.size()
      if i < prec then
        while i < prec do
          out.push('0')
          i = i + 1
        end
      else
        while i > prec do
          out.pop()
          i = i - 1
        end
      end
    end

    _format_s(consume out)

primitive _AlignLeft
primitive _AlignRight
primitive _AlignCenter
type _Align is ( _AlignLeft | _AlignRight | _AlignCenter)
