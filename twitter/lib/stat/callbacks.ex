defmodule Twitter.Stat do

  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  @impl true
  def init(:ok) do
    Logger.info("Starting Statictics module!")
    {:ok, {0, 0}}
  end

  @impl true
  def handle_cast(:count_up, {t0, count}) do
    {:noreply, {t0, count+1}}
  end

  @impl true
  def handle_cast(:start_timer, {_, count}) do
    {:noreply, {System.monotonic_time, count}}
  end

  @impl true
  def handle_call(:get_count, _from, {t0, count}) do
    {:reply, count, {t0, count}}
  end

  @impl true
  def handle_call(:stop_timer, _from, {t0, count}) do
    {:reply,
      System.convert_time_unit(System.monotonic_time-t0, :native, :milliseconds),
      {t0, count}
    }
  end

  @impl true
  def terminate(_, _) do
    Logger.warn("Shutting down Statictics module!")
  end

end
