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
  def handle_call({:login, client_pid, u_hash}, _from, {e_pid, u_list}) do
    Twitter.Client.Public.login(client_pid, u_hash, e_pid)
    {:reply, client_pid, {e_pid, u_list}}
  end
  ###########signup related

  ###########follow related
  @impl true
  def handle_cast({:follow, client_pid, to_hash}, {e_pid, u_list}) do
    Twitter.Client.Public.follow(client_pid, to_hash)
    {:noreply, {e_pid, u_list}}
  end
  ###########follow related

  ###########tweet related
  @impl true
  def handle_cast({:tweet, cli_pid, msg}, {e_pid, u_list}) do
    Twitter.Client.Public.tweet(cli_pid, msg)
    {:noreply, {e_pid, u_list}}
  end
  ############tweet related

  @impl true
  def terminate(_, _) do
    Logger.warn("Terminating the simulator...")
  end

end
