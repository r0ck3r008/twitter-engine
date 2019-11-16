defmodule Twitter.Api.Public do

  def hash_it(msg) do
    Salty.Hash.Sha256.hash(msg)
    |> elem(1)
    |> Base.encode16()
    |> String.slice(0, 8)
  end

  def fetch_users(of) do
    GenServer.call(of, :fetch_users)
  end

  def signup(of, client) do
    GenServer.cast(of, {:signup, client})
  end

  def login(of, u_hash) do
    {:ok, client_pid}=Twitter.Client.start_link
    GenServer.cast(of, {:login, client_pid, u_hash})
    client_pid
  end

  def logout(cli_pid) do
    Twitter.Client.Public.logout(cli_pid)
    GenServer.stop(cli_pid, :normal)
  end

  def follow(client_pid, to_hash) do
    Twitter.Client.Public.follow(client_pid, to_hash)
  end

  def tweet(client_pid, msg) do
    Twitter.Client.Public.tweet(client_pid, msg)
  end

end
