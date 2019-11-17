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
    GenServer.call(of, {:login, client_pid, u_hash})
    client_pid
  end

  def logout(cli_pid) do
    Twitter.Client.Public.logout(cli_pid)
    GenServer.stop(cli_pid, :normal)
  end

  #works for both user and tag
  def follow(client_pid, to_hash) do
    Twitter.Client.Public.follow(client_pid, to_hash)
  end

  def tweet(client_pid, msg) do
    Twitter.Client.Public.tweet(client_pid, msg)
  end

  #serves both for users and hastags
  def get_followed_tweets(cli_pid, followed_hash) do
    Twitter.Client.Public.get_tweets(cli_pid, followed_hash)
  end

  def get_self_tweets(cli_pid) do
    Twitter.Client.Public.get_tweets(cli_pid)
  end

end