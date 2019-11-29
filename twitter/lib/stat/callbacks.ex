defmodule Twitter.Stat do

  use GenServer
  require Logger

  def start_link(num) do
    GenServer.start_link(__MODULE__, num)
  end

  @impl true
  def init(num) do
    Logger.info("Starting Statictics module!")
    {:ok, {num, 0, 0}}
  end

  @impl true
  def handle_cast(:count_up, {num, t0, count}) do
    if count==(num-1) do
      tt=System.convert_time_unit(
                  System.monotonic_time-t0, :native, :millisecond)
      Logger.info("Time Taken for #{count} tweets: #{tt}ms!")
    end
    {:noreply, {num, t0, count+1}}
  end

  @impl true
  def handle_cast(:start_timer, {num, _, count}) do
    {:noreply, {num, System.monotonic_time, count}}
  end

  @impl true
  def handle_call(:get_count, _from, {num, t0, count}) do
    {:reply, count, {num, t0, count}}
  end

  @impl true
  def handle_call(:stop_timer, _from, {num, t0, count}) do
    {:reply,
      System.convert_time_unit(System.monotonic_time-t0, :native, :millisecond),
      {num, t0, count}
    }
  end

  @impl true
  def terminate(_, _) do
    Logger.warn("Shutting down Statictics module!")
  end

end
