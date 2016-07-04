
primitive Fmt
  fun apply(fmt: String box, args: (ReadSeq[Stringable] box | None) = None):
    String iso^
  =>
    let args' = match args
    | let rs: ReadSeq[Stringable] => rs
    else Array[Stringable]
    end

    let out = recover String end
    var i: USize = 0
    while i < fmt.size() do
      try
        let c = fmt(i)
        match c
        | '{' =>
          match fmt(i+1)
          | '{' =>
            out.push('{')
            i = i + 1
          else
            let fmt_to = fmt.find("}", i.isize())
            let parser = _FmtParser(fmt.substring(i.isize(), fmt_to), args')
            out.append(parser.parse())
            i = fmt_to.usize()
          end
        | '}' =>
          match fmt(i+1)
          | '}' =>
            out.push('}')
            i = i + 1
          else
            error
          end
        else
          out.push(c)
        end
      else
        out.push('?')
      end
      i = i + 1
    end
    out
