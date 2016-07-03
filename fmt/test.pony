use "ponytest"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestFmt)
    test(_TestIdent)

class iso _TestFmt is UnitTest
  fun name(): String => "Fmt"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("Hello", Fmt("Hello"))
    h.assert_eq[String]("Hello, world!", Fmt("Hello, {}!", ["world"]))

class iso _TestIdent is UnitTest
  fun name(): String => "Fmt._parse_ident"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("0, 1, 0, 2", Fmt("{}, {}, {0}, {}", ["0", "1", "2"]))
