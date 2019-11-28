defmodule Twitter.Stat.Public do

  def count_up(of) do
    GenServer.cast(of, :count_up)
  end

  def get_count(of) do
    GenServer.call(of, :get_count)
  end

  def start_timer(of) do
    GenServer.cast(of, :start_timer)
  end

  def stop_timer(of) do
    GenServer.call(of, :stop_timer)
  end

end
