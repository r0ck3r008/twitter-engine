defmodule Twitter.User do

  use GenServer
  require Logger

  def start_link(e_pid) do
    Logger.debug("Signing up the user...")
    {:ok, cli_agnt_pid}=Agent.start_link(fn-> [] end)
    GenServer.start_link(__MODULE__, {e_pid, cli_agnt_pid})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  #########signup related
  @impl true
  def handle_call({:signup, client_pid}, _from, {e_pid, cli_agnt_pid}) do
    u_hash=Twitter.Engine.Public.signup(e_pid, self())
    Agent.update(cli_agnt_pid, &Map.put(&1, client_pid))
    {:reply, u_hash, {e_pid, u_hash}}
  end

  @impl true
  def handle_cast({:login, cli_pid}, {e_pid, cli_agnt_pid}) do
    state=Agent.get(cli_agnt_pid, fn(state)->state end)
    Agent.update(cli_agnt_pid, &Map.put(&1, state++[cli_pid]))
    {:noreply, {e_pid, cli_agnt_pid}}
  end
  ##########signup related

  @impl true
  def terminate(_, _) do
    Logger.debug("Terminating the user...")
  end

end
