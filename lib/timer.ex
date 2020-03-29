# Instructions
#
# Simulate a timer that counts down seconds. A test suite has been provided that
# can be run with the command TimerTests.run().
#
# The timer should be able to be accessed from multiple processes. It should
# support pausing and unpausing the countdown. After a countdown reaches 0, the
# process should stop.

defmodule Timer do
  @moduledoc """
  A countdown timer that can be accessed from multiple processes.
  """

  @spec start_timer(seconds :: non_neg_integer()) :: pid()
  def start_timer(_seconds \\ 0) do
  end

  @spec pause_timer(pid()) :: :ok
  def pause_timer(_pid) do
  end

  @spec unpause_timer(pid()) :: :ok
  def unpause_timer(_pid) do
  end

  @spec cancel_timer(pid()) :: :ok
  def cancel_timer(_pid) do
  end

  @spec get_seconds(pid()) :: non_neg_integer()
  def get_seconds(_pid) do
  end
end

defmodule TimerTests do
  @tests [:test_one, :test_two, :test_three, :test_four, :test_five, :test_six, :test_seven]

  def run do
    tests = Enum.map(@tests, fn test -> apply(__MODULE__, test, []) end)
    pass_count = Enum.count(tests, &(&1 === :passed))
    fail_count = Enum.count(tests, &(&1 === :failed))
    IO.puts("\n#{pass_count} passed, #{fail_count} failed")
  end

  def test_one do
    log("starts counting down from initial seconds")

    pid = Timer.start_timer(10)
    seconds = Timer.get_seconds(pid)
    expected_seconds = 10

    assert(expected_seconds, seconds)
  end

  def test_two do
    log("returns correct seconds left during countdown")

    pid = Timer.start_timer(2)
    :timer.sleep(1000)
    seconds = Timer.get_seconds(pid)
    expected_seconds = 1

    assert(expected_seconds, seconds)
  end

  def test_three do
    log("timer process stops after countdown ends")
    this = self()

    spawn(fn ->
      pid = Timer.start_timer(1)
      send(this, {:continue, pid})
    end)

    pid =
      receive do
        {:continue, pid} -> pid
      after
        1000 -> raise "timeout"
      end

    :timer.sleep(2500)

    is_alive = is_pid(pid) and Process.alive?(pid)
    expected_to_be_alive = false

    assert(expected_to_be_alive, is_alive)
  end

  def test_four do
    log("pausing stops the countdown")

    pid = Timer.start_timer(2)
    :timer.sleep(1000)
    Timer.pause_timer(pid)
    :timer.sleep(1000)
    seconds = Timer.get_seconds(pid)
    expected_seconds = 1

    assert(expected_seconds, seconds)
  end

  def test_five do
    log("unpausing resumes the countdown")

    pid = Timer.start_timer(5)
    Timer.pause_timer(pid)
    Timer.unpause_timer(pid)
    :timer.sleep(1500)
    seconds = Timer.get_seconds(pid)
    expected_seconds = 3

    assert(expected_seconds, seconds)
  end

  def test_six do
    log("timer can be paused from a different process")

    pid = Timer.start_timer(5)
    this = self()

    spawn(fn ->
      Timer.pause_timer(pid)
      send(this, :continue)
    end)

    receive do
      :continue -> :ok
    after
      1000 -> raise "timeout"
    end

    seconds = Timer.get_seconds(pid)
    expected_seconds = 5

    assert(expected_seconds, seconds)
  end

  def test_seven do
    log("timer returns 0 seconds after it is canceled")

    pid = Timer.start_timer(10)
    Timer.cancel_timer(pid)
    seconds = Timer.get_seconds(pid)
    expected_seconds = 0

    assert(expected_seconds, seconds)
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

  defp failed(expected, result) do
    IO.puts(
      IO.ANSI.red() <>
        "expected: #{inspect(expected)}, got: #{inspect(result)}" <> IO.ANSI.reset()
    )

    :failed
  end
end
