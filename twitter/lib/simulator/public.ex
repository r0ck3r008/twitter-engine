defmodule Twitter.Simulator.Public do

  def hash_it(msg) do
    Salty.Hash.Sha256.hash(msg)
    |> elem(1)
    |> Base.encode16()
    |> String.slice(0, 8)
  end

  def signup(of, client) do
    GenServer.cast(of, {:signup, client})
  end

  def login(of, u_hash) do
    {:ok, client_pid}=Twitter.Client.start_link
    GenServer.call(of, {:login, client_pid, u_hash})
    client_pid
  end

  def follow(of, client_pid, to_hash) do
    GenServer.cast(of, {:follow, client_pid, to_hash})
  end

end
