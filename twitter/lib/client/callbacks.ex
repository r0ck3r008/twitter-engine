defmodule Twitter.Client do

  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  @impl true
  def init(:ok) do
    {:ok, []}
  end

  ##########signup related
  @impl true
  def handle_cast({:signup, e_pid},  _) do
    {:ok, u_pid}=Twitter.User.start_link(e_pid)
    {u_hash, cli_hash}=Twitter.User.Public.signup(u_pid, self())
    {:noreply, {u_hash, u_pid, e_pid}}
  end

  @impl true
  def handle_cast({:login u_hash, e_pid},  _) do
    u_pid=Twitter.Engine.Public.login(e_pid, u_hash, self())
    {:noreply, {u_hash, u_pid, e_pid}}
  end
  ###########signup related
  
  ###########follow related
  @impl true
  def handle_cast({:follow, to_hash}, e_pid) do

  end

  @impl true
  def terminate(_, _) do
    Logger.debug("Terminating the client...")
  end

end
