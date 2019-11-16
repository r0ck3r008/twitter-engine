defmodule Twitter.Api do

  use GenServer
  require Logger

  def start_link(e_pid) do
    Logger.info("Starting the similator...")
    GenServer.start_link(__MODULE__, {e_pid, []})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:fetch_users, _from, {e_pid, u_list}) do
    {:reply, u_list, {e_pid, u_list}}
  end

  ##########signup related
  @impl true
  def handle_cast({:signup, client_pid}, {e_pid, u_list}) do
    u_hash=Twitter.Client.Public.signup(client_pid, e_pid)
    {:noreply, {e_pid, u_list++[u_hash]}}
  end

  @impl true
  def handle_cast({:login, cli_pid, u_hash}, {e_pid, u_list}) do
    Twitter.Client.Public.login(cli_pid, u_hash, e_pid)
    {:noreply, {e_pid, u_list}}
  end
  ###########signup related

  @impl true
  def terminate(_, _) do
    Logger.warn("Terminating the simulator...")
  end

end
