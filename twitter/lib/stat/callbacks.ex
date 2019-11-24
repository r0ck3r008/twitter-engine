defmodule Twitter.Stat do

  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  @impl true
  def init(:ok) do
    Logger.info("Starting Statictics module!")
    {:ok, 0}
  end

  @impl true
  def handle_cast(:tweet_up, count) do
    {:noreply, count+1}
  end

  @impl true
  def handle_call(:get_tweets, _from, count) do
    {:reply, count, count}
  end

  @impl true
  def terminate(_, _) do
    Logger.warn("Shutting down Statictics module!")
  end

end
