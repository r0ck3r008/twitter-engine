defmodule Twitter.Engine do

  use GenServer
  require Logger

  def start_link do
    Logger.info("Starting the engine...")
    {:ok, u_agnt_pid}=Agent.start_link(fn-> %{} end)
    {:ok, fol_agnt_pid}=Agent.start_link(fn-> %{} end)
    GenServer.start_link(__MODULE__, {u_agnt_pid, fol_agnt_pid})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  ##########signup related
  @impl true
  def handle_call({:signup, u_pid}, _from, {u_agnt_pid, fol_agnt_pid}) do
    u_hash=Twitter.Engine.Public.hash_it(inspect u_pid)
    Agent.update(u_agnt_pid, &Map.put(&1, u_hash, u_pid))
    {:reply, u_hash, {u_agnt_pid, fol_agnt_pid}}
  end

  @impl true
  def handle_call({:login, u_hash, cli_pid}, _from, {u_agnt_pid, fol_agnt_pid}) do
    u_pid=Agent.get(u_agnt_pid, &Map.get(&1, u_hash))
    Twitter.User.Public.login(u_pid, cli_pid)
    {:reply, u_pid, {u_agnt_pid, fol_agnt_pid}}
  end
  ##########signup related
  
  ##########follow related
  @impl true
  def handle_cast({:follow, u_hash, to_hash}, {u_agnt_pid, fol_agnt_pid}) do
    state=Agent.get(fol_agnt_pid, &Map.get(&1, to_hash))
    case state do
      nil->
        Agent.put(fol_agnt_pid, &Map.put(&1, to_hash, [u_hash]))
      _->
        Agent.put(fol_agnt_pid, &Map.put(&1, to_hash, state++[u_hash]))
    end
    {:noreply, {u_agnt_pid, fol_agnt_pid}}
  end
  ###########follow related

  @impl true
  def terminate(_, _) do
    Logger.warn("Stopping the engine...")
  end

end
