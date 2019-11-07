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
  def handle_call({:signup, e_pid}, _from, _) do
    {:ok, u_pid}=Twitter.User.start_link(e_pid)
    {u_hash, cli_hash}=Twitter.User.Public.signup(u_pid, self())
    {:reply, _, u_hash}
  end
  ###########signup related

  @impl true
  def terminate(_, _) do
    Logger.debug("Terminating the client...")
  end

end
