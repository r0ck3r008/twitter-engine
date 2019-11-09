defmodule Twitter.Simulator.Public do

  def hash_it(msg) do
    Salty.Hash.Sha256.hash(msg)
    |> elem(1)
    |> Base.encode16()
    |> String.slice(0, 8)
  end

  def signup(client_pid) do

  end

  def login(u_hash) do

  end

  def follow(u_hash, to_hash) do

  end

end
