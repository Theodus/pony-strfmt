
primitive Fmt
  fun apply(fmt: String box, args: (ReadSeq[Stringable] | None) = None):
    String iso^
  =>
    let args' = match args
    | let rs: ReadSeq[Stringable] => rs
    else Array[Stringable]
    end

    var s = recover String end
    var i: USize = 0
    var default: USize = 0
    while i < fmt.size() do
      let c = try fmt(i) else '' end
      if c == '{' then
        (i, default, s) = _parse_fmt(consume s, args', fmt, i+1, default)
      else
        s.push(c)
        i = i + 1
      end
    end
    consume s

  fun _parse_fmt(s: String iso, args: ReadSeq[Stringable], fmt: String box,
    offset: USize, default: USize): (USize, USize, String iso^)
  =>
    let c = try fmt(offset) else '' end
    match c
    | '{' =>
      s.push(c)
      (offset+1, default, consume s)
    | '}' =>
      try s.append(args(default).string()) end
      (offset+1, default+1, consume s)
    else
      _parse_ident(consume s, args, fmt, offset, default)
    end

  fun _parse_ident(s: String iso, args: ReadSeq[Stringable], fmt: String box,
    offset: USize, default: USize): (USize, USize, String iso^)
  =>
    var offset' = offset
    try
      (let ident, let used) = fmt.read_int[USize](offset'.isize(), 10)
      s.append(args(ident).string())
      offset' = offset' + (used + 1)
    end

    let c = try fmt(offset') else '' end
    match c
    | ':' => (offset', default, consume s)//_parse_spec(consume s, args, fmt, offset', default)
    else (offset', default, consume s)
    end
