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
  def handle_call({:signup, e_pid}, _from,  _) do
    {:ok, u_pid}=Twitter.User.start_link(e_pid)
    u_hash=Twitter.User.Public.signup(u_pid, self())
    Logger.debug("Signup success #{u_hash}")
    {:reply, u_hash, {u_hash, u_pid, e_pid}}
  end

  @impl true
  def handle_cast({:login, u_hash, e_pid},  _) do
    u_pid=Twitter.Relay.Public.login(e_pid, u_hash, self())
    {:noreply, {u_hash, u_pid, e_pid}}
  end

  @impl true
  def handle_call(:logout, _from, {u_hash, u_pid, e_pid}) do
    Twitter.User.Public.logout(u_pid, self())
    {:reply, :ok, {u_hash, u_pid, e_pid}}
  end
  ###########signup related

  ###########follow related
  @impl true
  def handle_cast({:follow, to_hash}, {u_hash, u_pid, e_pid}) do
    Twitter.User.Public.follow(u_pid, self(), to_hash)
    {:noreply, {u_hash, u_pid, e_pid}}
  end
  ###########follow related

  ###########tweet related
  @impl true
  def handle_cast({:tweet, msg}, {u_hash, u_pid, e_pid}) do
    case Twitter.User.Public.tweet(u_pid, self(), msg) do
      :ok->
        Logger.info("Tweet #{msg} sent as user #{u_hash}")
      _->
        Logger.error("Tweet #{msg} failed to send as user #{u_hash}")
    end
    {:noreply, {u_hash, u_pid, e_pid}}
  end
  ###########tweet related

  @impl true
  def terminate(_, _) do
    Logger.debug("Terminating the client...")
  end

end
