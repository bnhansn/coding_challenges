# Instructions
#
# Implement the reverse/1, map/2, and uniq_by/2 functions from the Enum module
# with using any functions from the Enum module. The functions should support
# both Lists and Maps.
#
# A test suite has been provided, it can be run with MyEnumTests.run().

defmodule MyEnum do
  @spec reverse(Enum.t()) :: list()
  def reverse(enumerable) do
    enumerable
  end

  @spec map(Enum.t(), (any() -> any())) :: list()
  def map(enumerable, _fun) do
    enumerable
  end

  @spec uniq_by(Enum.t(), (any() -> any())) :: list()
  def uniq_by(enumerable, _fun) do
    enumerable
  end
end

defmodule MyEnumTests do
  @tests [:test_one, :test_two, :test_three, :test_four, :test_five, :test_six]
  @simple_list [1, 2, 3]
  @simple_map %{"tony" => "stark", "peter" => "parker", "bruce" => "banner"}
  @dup_list [1, 2, 3, 3, 2]
  @dup_map %{"thor" => "marvel", "loki" => "marvel", "batman" => "dc"}

  def run do
    tests = Enum.map(@tests, fn test -> apply(__MODULE__, test, []) end)
    pass_count = Enum.count(tests, &(&1 === :passed))
    fail_count = Enum.count(tests, &(&1 === :failed))
    IO.puts("\n#{pass_count} passed, #{fail_count} failed")
  end

  def test_one do
    log("reverse/1 with a List")

    expected = Enum.reverse(@simple_list)
    actual = MyEnum.reverse(@simple_list)

    assert(expected, actual)
  end

  def test_two do
    log("reverse/1 with a Map")

    expected = Enum.reverse(@simple_map)
    actual = MyEnum.reverse(@simple_map)

    assert(expected, actual)
  end

  def test_three do
    log("map/2 with a List")

    fun = fn i -> i * 2 end
    expected = Enum.map(@simple_list, fun)
    actual = MyEnum.map(@simple_list, fun)

    assert(expected, actual)
  end

  def test_four do
    log("map/2 with a Map")

    fun = fn {k, v} -> {String.capitalize(k), String.capitalize(v)} end
    expected = Enum.map(@simple_map, fun)
    actual = MyEnum.map(@simple_map, fun)

    assert(expected, actual)
  end

  def test_five do
    log("uniq_by/1 with a List")

    fun = fn i -> i end
    expected = Enum.uniq_by(@dup_list, fun)
    actual = MyEnum.uniq_by(@dup_list, fun)

    assert(expected, actual)
  end

  def test_six do
    log("uniq_by/1 with a Map")

    fun = fn {_k, v} -> v end
    expected = Enum.uniq_by(@dup_map, fun)
    actual = MyEnum.uniq_by(@dup_map, fun)

    assert(expected, actual)
  end

  defp assert(expected, actual) when expected == actual, do: passed()
  defp assert(expected, actual), do: failed(expected, actual)

  defp log(msg) do
    IO.puts(IO.ANSI.yellow() <> ">>> #{msg}" <> IO.ANSI.reset())
  end

  defp passed do
    IO.puts(IO.ANSI.green() <> "passed" <> IO.ANSI.reset())
    :passed
  end

  defp failed(expected, actual) do
    IO.puts(
      IO.ANSI.red() <>
        "expected: #{inspect(expected)}, got: #{inspect(actual)}" <> IO.ANSI.reset()
    )

    :failed
  end
end
