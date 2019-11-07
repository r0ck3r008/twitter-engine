defmodule Twitter.Client.Public do

  def signup(client_pid, e_pid) do
    GenServer.call(client_pid, {:signup, e_pid})
  end

end
