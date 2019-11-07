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

  ##########signup related
  @impl true
  def handle_call({:signup, u_pid}, _from, state) do
    u_hash=Twitter.Engine.Public.hash_it(inspect u_pid)
    Agent.update(u_agnt_pid, &Map.put(&1, u_hash, u_pid))
    {:reply, u_hash, u_agnt_pid}
  end
  ##########signup related

  @impl true
  def terminate(_, _) do
    Logger.warn("Stopping the engine...")
  end

end
