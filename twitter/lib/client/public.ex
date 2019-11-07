defmodule Twitter.Client.Public do

  def signup(client_pid, e_pid) do
    GenServer.cast(client_pid, {:signup, e_pid})
  end

  def login(client_pid, u_hash, e_pid) do
    GenServer.cast(client_pid, {:login, u_hash, e_pid})
  end

end
