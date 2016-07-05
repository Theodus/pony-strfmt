use "ponytest"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestFmt)

class iso _TestFmt is UnitTest
  fun name(): String => "Fmt"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("Hello", Fmt("Hello"))
    h.assert_eq[String]("{Hello}", Fmt("{{Hello}}"))

    h.assert_eq[String]("Hello, world!", Fmt("Hello, {}!", ["world"]))
    h.assert_eq[String]("0, 1, 0, 2", Fmt("{}, {}, {0}, {}", ["0", "1", "2"]))

    h.assert_eq[String]("left      ", Fmt("{:<10}", ["left"]))
    h.assert_eq[String]("     right", Fmt("{:>10}", ["right"]))
    h.assert_eq[String]("  center  ", Fmt("{:^10}", ["center"]))

    h.assert_eq[String]("42 2a 52 101010", Fmt("{0:d} {0:x} {0:o} {0:b}",
      [USize(42)]))
    h.assert_eq[String]("2A", Fmt("{:X}", [USize(42)]))
    h.assert_eq[String]("0x2a 0o52 0b101010", Fmt("{0:#x} {0:#o} {0:#b}",
      [USize(42)]))

    h.assert_eq[String]("1.23", Fmt("{:.2}", [F64(1.234567)]))
    h.assert_eq[String]("+3.1400, -3.1400", Fmt("{:+f}, {:+f}",
      [F64(3.14), F64(-3.14)]))
    h.assert_eq[String](" 3.1400, -3.1400", Fmt("{: f}, {: f}",
      [F64(3.14), F64(-3.14)]))
    h.assert_eq[String]("3.1400, -3.1400", Fmt("{:-f}, {:-f}",
      [F64(3.14), F64(-3.14)]))

    // TODO comma insertion
    //h.assert_eq[String]("1,234,567,890", Fmt("{:,}", [I64(1234567890)]))
