
class _FmtParser
  let _fmt: String box
  let _args: ReadSeq[Stringable] box
  var _offset: USize = 0
  var _default: USize = 0

  var _align: _Align = _AlignLeft
  var _align_fill: U8 = ' '
  var _padding: USize = 0
  var _pre: String = ""
  var _width: USize = -1
  var _prec: USize = 0

  new create(fmt: String box, args: ReadSeq[Stringable] box) =>
    _fmt = fmt
    _args = args

  fun ref parse(): String iso^ ? =>
    error

  fun ref _next(): U8 ? =>
    _offset = _offset + 1
    _fmt(_offset-1)

  fun ref _backup() =>
    _offset = _offset - 1

primitive _AlignLeft
primitive _AlignRight
primitive _AlignCenter
type _Align is ( _AlignLeft | _AlignCenter | _AlignRight)
