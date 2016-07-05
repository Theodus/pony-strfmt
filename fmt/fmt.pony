
primitive Fmt
  fun apply(fmt: String box, args: (ReadSeq[(String | Number)] | None) = None):
    String iso^
  =>
    let args' = match args
    | let rs: ReadSeq[(String | Number)] => rs
    else Array[(String | Number)]
    end

    let out = recover String end
    var i: USize = 0
    var default: USize = 0
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
            let arg = try
              (let a, let u) = fmt.read_int[USize](i.isize()+1)
              if u == 0 then
                error
              else
                i = i + (u + 1)
                args'(a)
              end
            else
              default = default + 1
              i = i + 1
              args'(default-1)
            end

            match fmt(i)
            | ':' =>
              let spec_from = i.isize() + 1
              let spec_to = fmt.find("}", i.isize())
              let format = _Format(fmt.substring(spec_from, spec_to), arg)
              out.append(format())
              i = spec_to.usize()
            | '}' =>
              out.append(arg.string())
            else
              error
            end
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
