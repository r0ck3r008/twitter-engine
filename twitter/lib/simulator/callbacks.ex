defmodule Twitter.Simulator do

  use GenServer
  require Logger

  def start_link(e_pid, num) do
    Logger.info("Starting the similator...")
    GenServer.start_link(__MODULE__, {e_pid, num})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  ##########signup related


  @impl true
  def terminate(_, _) do
    Logger.warn("Terminating the simulator...")
  end

end
