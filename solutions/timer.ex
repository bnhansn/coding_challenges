defmodule Timer do
  @moduledoc """
  A countdown timer that can be accessed from multiple processes.
  """

  use GenServer

  defstruct [:seconds, paused: false]

  def start_link(seconds) do
    timer = %Timer{seconds: seconds}
    GenServer.start_link(__MODULE__, timer)
  end

  @spec start_timer(seconds :: non_neg_integer()) :: pid()
  def start_timer(seconds \\ 0) do
    {:ok, pid} = start_link(seconds)
    pid
  end

  @spec pause_timer(pid()) :: :ok
  def pause_timer(pid) do
    GenServer.cast(pid, :pause)
  end

  @spec unpause_timer(pid()) :: :ok
  def unpause_timer(pid) do
    GenServer.cast(pid, :unpause)
  end

  @spec cancel_timer(pid()) :: :ok
  def cancel_timer(pid) do
    GenServer.stop(pid)
  end

  @spec get_seconds(pid()) :: non_neg_integer()
  def get_seconds(pid) do
    if Process.alive?(pid) do
      GenServer.call(pid, :get_seconds)
    else
      0
    end
  end

  @impl GenServer
  def init(timer) do
    Process.send_after(self(), :countdown, 1000)
    {:ok, timer}
  end

  @impl GenServer
  def handle_call(:get_seconds, _from, timer) do
    {:reply, timer.seconds, timer}
  end

  @impl GenServer
  def handle_cast(:pause, timer) do
    {:noreply, %Timer{timer | paused: true}}
  end

  def handle_cast(:unpause, timer) do
    Process.send_after(self(), :countdown, 1000)
    {:noreply, %Timer{timer | paused: false}}
  end

  @impl GenServer
  def handle_info(:countdown, %Timer{paused: true} = timer) do
    {:noreply, timer}
  end

  def handle_info(:countdown, %Timer{seconds: 0} = timer) do
    {:stop, :normal, timer}
  end

  def handle_info(:countdown, %Timer{seconds: seconds} = timer) do
    Process.send_after(self(), :countdown, 1000)
    {:noreply, %Timer{timer | seconds: seconds - 1}}
  end
end
