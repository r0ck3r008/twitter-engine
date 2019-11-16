defmodule Twitter.Client.Public do

  def signup(of, e_pid) do
    GenServer.call(of, {:signup, e_pid})
  end

  def login(of, u_hash, e_pid) do
    GenServer.cast(of, {:login, u_hash, e_pid})
  end

  def logout(of) do
    GenServer.call(of, :logout)
  end

  def follow(of, to_hash) do
    GenServer.cast(of, {:follow, to_hash})
  end

  def tweet(of, msg) do
    GenServer.cast(of, {:tweet, msg})
  end

end
