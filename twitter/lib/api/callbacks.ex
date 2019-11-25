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
  def handle_call({:signup, client_pid}, _from, {e_pid, u_list}) do
    u_hash=Twitter.Client.Public.signup(client_pid, e_pid)
    {:reply, u_hash, {e_pid, u_list++[u_hash]}}
  end

  @impl true
  def handle_call({:del_usr, cli_pid}, _from, {e_pid, u_list}) do
    u_hash=Twitter.Client.Public.delete_user(cli_pid)
    Logger.debug("Deleted user #{u_hash}")
    GenServer.stop(cli_pid, :normal)
    {:reply, :ok, {e_pid, u_list--[u_hash]}}
  end

  @impl true
  def handle_call({:login, cli_pid, u_hash}, _from, {e_pid, u_list}) do
    Twitter.Client.Public.login(cli_pid, u_hash, e_pid)
    {:reply, :ok, {e_pid, u_list}}
  end
  ###########signup related
  
  ###########test realted
  @impl true
  def handle_call({:user?, u_hash}, _from, {e_pid, u_list}) do
    if u_hash in u_list do
      {:reply, true, {e_pid, u_list}}
    else
      {:reply, false, {e_pid, u_list}}
    end
  end

  @impl true
  def terminate(_, _) do
    Logger.warn("Terminating the simulator...")
  end

end
