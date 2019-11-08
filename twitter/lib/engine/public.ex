defmodule Twitter.Engine.Public do

  def hash_it(msg) do
    Salty.Hash.Sha256.hash(msg)
    |> elem(1)
    |> Base.encode16()
    |> String.slice(0, 8)
  end

  def signup(of, u_pid) do
    GenServer.call(of, {:signup, u_pid})
  end

  def login(of, u_hash, cli_pid) do
    GenServer.call(of, {:login, u_hash, cli_pid})
  end

  def follow(of, u_hash, to_hash) do
    GenServer.cast(of, {:follow, u_hash, to_hash})
  end

end
