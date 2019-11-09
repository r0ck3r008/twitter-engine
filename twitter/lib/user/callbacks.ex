defmodule Twitter.User do

  use GenServer
  require Logger

  def start_link(e_pid) do
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
    Agent.update(cli_agnt_pid, &(&1++[client_pid]))
    {:reply, u_hash, {e_pid, cli_agnt_pid, u_hash}}
  end

  @impl true
  def handle_cast({:login, cli_pid}, {e_pid, cli_agnt_pid, u_hash}) do
    Agent.update(cli_agnt_pid, &(&1++[cli_pid]))
    Logger.debug("Login Success from client #{inspect cli_pid} to #{u_hash}")
    {:noreply, {e_pid, cli_agnt_pid, u_hash}}
  end
  ##########signup related
  
  ##########follow related
  @impl true
  def handle_cast({:follow, cli_pid, to_hash}, {e_pid, cli_agnt_pid, u_hash}) do
    state=Agent.get(cli_agnt_pid, fn(state)-> state end)
    if cli_pid in state do
      Twitter.Engine.Public.follow(e_pid, u_hash, to_hash)
    else
      Logger.warn("Follow request denied, client not logged in!")
    end
    {:noreply, {e_pid, cli_agnt_pid, u_hash}}
  end
  ###########follow related

  @impl true
  def terminate(_, _) do
    Logger.debug("Terminating the user...")
  end

end
