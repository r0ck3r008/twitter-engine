defmodule Twitter.Engine do

  use GenServer
  require Logger

  def start_link do
    Logger.info("Starting the engine...")
    {:ok, u_agnt_pid}=Agent.start_link(fn-> %{} end)
    GenServer.start_link(__MODULE__, {u_agnt_pid})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def terminate(_, _) do
    Logger.warn("Stopping the engine...")
  end

end
