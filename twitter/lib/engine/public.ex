defmodule Twitter.Engine.Public do

  def hash_it(msg) do
    Salty.Hash.Sha256(msg)
    |> elem(1)
    |> Base.encode16()
    |> String.split(0, 8)
  end

  def signup(of, u_pid) do
    GenServer.call(of, {:signup, u_pid})
  end

end
